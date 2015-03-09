// Format of an ELF executable file

#define ELF_MAGIC 0x464C457FU  // "\x7FELF" in little endian

// File header
struct elfhdr {
  uint magic; 	// must equal ELF_MAGIC标识文件是否是ELF 文件
  uchar elf[12];	// 魔数和相关信息
  ushort type;	// 文件类型
  ushort machine; // 针对体系结构
  uint version;	// 版本信息
  uint entry; 	// 程序入口的虚拟地址
  uint phoff; 	// program header 表的位置偏移
  uint shoff;		//节头表偏移量
  uint flags;	// 处理器特定标志
  ushort ehsize;	// 文件头长度
  ushort phentsize; // program header 表长度
  ushort phnum; //program header 表中的入口数目
  ushort shentsize;	// 节头部长度
  ushort shnum;		// 节头部个数
  ushort shstrndx;	// 节头部字符索引
};

// Program section header
struct proghdr {
  uint type; 	// 段类型
  uint offset; 	// 段相对文件头的偏移值
  uint vaddr; 	// 段的第一个字节将被放到内存中的虚拟地址
  uint paddr;	// 段的物理地址
  uint filesz;	// 段在文件中的长度
  uint memsz; 	// 段在内存映像中占用的字节数
  uint flags;	// 段标志
  uint align;	// 段在内存中的对齐标志
};

// Values for Proghdr type
#define ELF_PROG_LOAD           1

// Flag bits for Proghdr flags
#define ELF_PROG_FLAG_EXEC      1
#define ELF_PROG_FLAG_WRITE     2
#define ELF_PROG_FLAG_READ      4
