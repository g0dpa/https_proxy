import os, sys, socket, re, ssl
from OpenSSL import SSL
from threading import Thread

MAX_QUEUE = 20          # Max number of connection
MAX_PKT_SIZE = 99999     # Max size of packet

# g0dpa's SSL proxy
# create root certification and apply to web-brower if necessary before running SSL proxy

def usage():
    print("syntax : python https_proxy <port>")
    print("sample : python https_proxy 4433")
    sys.exit(1)

def initCert():
    # initialize cert
    cmd = 'cd cert-master && sh _clear_site.sh'
    os.system(cmd)
    cmd = 'cd cert-master && sh _init_site.sh '
    os.system(cmd)

def genCert(webserver):
    # generate certification
    cmd = 'cd cert-master && sh _make_site.sh '+ webserver
    os.system(cmd)

def setServer():
    print('+++ HTTPS_Proxy Server Running')
    print('+++ If you want to Quit, Press Ctrl-C')

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.bind((HOST, PORT))
    sock.listen(MAX_QUEUE)

    return sock

def runProxy(sock):

    # get request from web browser
    request = sock.recv(MAX_PKT_SIZE).decode()
    if not request.startswith("CONNECT"): return
    host, port= re.search("Host: ([\w.-:]*)", request).group(1).split(":")
    port = int(port) # port = 443

    sock.send('HTTP/1.1 200 Connection established\r\nConnection: close\r\n\r\n'.encode())

    certPath = os.path.join("cert-master", host)
    lock.acquire()
    if not os.path.isfile(certPath):
        genCert(host)
    lock.release()
    pemFile = certPath + ".pem"

    # wrap sock as ssl with certification
    try:
        ssl_sock = ssl.wrap_socket(sock, server_side = True, certfile = pemFile)
    except Exception as e:
        print e

    try:
        try:
            ssl_server = ssl.wrap_socket(socket.socket(socket.AF_INET, socket.SOCK_STREAM))
            ssl_server.connect((host, port))
        except Exception as e:
            ssl_server.close()
            ssl_sock.close()
            print e
            sys.exit(1)

        while True:
            # receive ssl request from web browser
            ssl_request = ssl_sock.recv(MAX_PKT_SIZE)
            # send ssl request to end-server
            ssl_server.send(ssl_request)
            # receive data from end-server
            data = ssl_server.recv(MAX_PKT_SIZE)
            if (len(data) > 0):
                # send to data browser
                ssl_sock.send(data)
            else:
                break
            ssl_server.close()
            ssl_sock.close()
    except Exception as e:
        ssl_server.close()
        ssl_sock.close()
        print e
        sys.exit(1)

if __name__=='__main__':
    
    if (len(sys.argv)<2):
        usage()
    else:
        HOST = 'localhost'
        PORT = int(sys.argv[1])

    sock = setServer()
    conn_list=[]
    initCert()
    lock = threading.Lock()
    while True:
        try:
            conn, addr = sock.accept()
            t = Thread(target = runProxy, args = (conn,))
            # Daemon Thread dies if main thread dies > Don't need to kill background thread
            t.daemon = True
            conn_list.append(t)
            t.start()

        except KeyboardInterrupt:
            sock.close()
            print("--- Proxy Server OUT...")
            sys.exit(1)
