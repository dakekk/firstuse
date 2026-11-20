"""根目录的测试文件：提供一个最小的可运行示例。"""


def add(a, b):
    """返回两个数之和。"""
    return a + b


if __name__ == "__main__":
    assert add(1, 2) == 3
    print("test.py ok")
