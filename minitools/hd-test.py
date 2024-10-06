import hashlib
import sys
import fcntl
import struct
import os
import time

def get_size(device_path):
    req = 0x80081272
    buf = b' ' * 8
    fmt = 'L'

    with open(device_path) as dev:
        buf = fcntl.ioctl(dev.fileno(), req, buf)

    return struct.unpack('L', buf)[0]

prefixes = ['', 'k', 'M', 'G', 'T']

def fmt(size, *, unit='B', power=2**10):
    for prefix in prefixes:
        if size < power:
            return f"{size:.2f}{prefix}{unit}"
        size /= power

def stats(start, size, done):
    t = time.perf_counter() - start
    print(f"Status {t:3.3f}s, {fmt(done)}, {done/size*100:3.2f}%, {fmt(done/t, unit='B/s')}")

def main(device_path):
    print(f"Device {device_path}")
    size = get_size(device_path)
    print(f"Device size {fmt(size)}")

    block_size = 2**20
    # block_size = 1548288
    if size % block_size != 0:
        raise Exception(f"not aligned blocks {size}, {block_size}, {size % block_size}")
    block_count = size // block_size
    block = bytearray(os.urandom(block_size))

    md5_write = hashlib.md5()
    with open(device_path, 'wb') as handle:
        start = time.perf_counter()
        for i in range(block_count):
            handle.write(block)
            md5_write.update(block)
            if i % 1024 == 0:
                stats(start, size, block_size*i)
        handle.flush()
        write_time = time.perf_counter() - start
        print(f"Write in {write_time:.3}s")
        print(f"Write speed {fmt(size/write_time, unit='B/s')}")
    print("Hash", md5_write.hexdigest())

    md5_read = hashlib.md5()
    with open(device_path, 'rb') as handle:
        start = time.perf_counter()
        i = 0
        for chunk in iter(lambda: handle.read(4096), b''):
            md5_read.update(chunk)
            size += len(chunk)
            if size % (1024 * 1024) == 0:
                stats(start, size, block_size*i)
            i++
        read_time = time.perf_counter() - start
        print("Read in", read_time)
        print(f"read speed {fmt(size/read_time, unit='B/s')}")
    print("Hash", md5_write.hexdigest())
    if md5_write.digest() == md5_read.digest():
        print("OK")
    else:
        print("FCUK")

if __name__ == '__main__':
    main(sys.argv[1])
