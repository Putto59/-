#!/usr/bin/env bash
#
# ลิขสิทธิ์ (c) ผู้พัฒนา Bitcoin Core
# เผยแพร่ภายใต้ MIT software license
# ดูไฟล์ COPYING หรือ http://www.opensource.org/licenses/mit-license.php เพื่อข้อมูลเพิ่มเติม

export LC_ALL=C.UTF-8

# ตั้งค่าการทำงานเพื่อหยุดเมื่อเกิดข้อผิดพลาด
set -o errexit -o pipefail -o xtrace

# แสดงข้อมูล Commit ล่าสุด
echo "กำลังทดสอบ commit ล่าสุดบน $( git log -1 )"

# ใช้ clang++ เนื่องจากเร็วกว่าและใช้หน่วยความจำน้อยกว่า g++
CC=clang CXX=clang++ cmake -B build -DWERROR=ON -DWITH_ZMQ=ON -DBUILD_GUI=ON -DBUILD_BENCH=ON -DBUILD_FUZZ_BINARY=ON -DWITH_USDT=ON -DCMAKE_CXX_FLAGS='-Wno-error=unused-member-function'

# สร้างโครงสร้างโปรแกรม (build) โดยใช้ cmake
cmake --build build -j "$( nproc )"

# รันชุดการทดสอบและแสดงผลเมื่อเกิดข้อผิดพลาด
ctest --output-on-failure --stop-on-failure --test-dir build -j "$( nproc )"

# รัน Functional Test โดยใช้ Python script
./build/test/functional/test_runner.py -j $(( $(nproc) * 2 )) --combinedlogslen=99999999