// const size4  = 0x0_00_00_00_10;
// const size5  = 0x0_00_00_00_20;
// const size7  = 0x0_00_00_00_80;
// const size8  = 0x0_00_00_01_00;
// const size16 = 0x0_00_01_00_00;
// const size31 = 0x0_80_00_00_00;
// const size32 = 0x1_00_00_00_00;
// const size34 = 0x4_00_00_00_00;

const	mask4  = 0x0f;
const	mask5  = 0x1f;
const	mask6  = 0x3f;

const	mask8  = 0xff;
const size8  = mask8 + 1;
const	mask7  = mask8 >> 1;

const	mask16 = 0xffff;
const size16 = mask16 + 1;
const mask15 = mask16 >> 1;

const	mask32 = 0xffffffff;
const size32 = mask32 + 1;
const	mask31 = mask32 >> 1;

const	mask34 = 0x03ffffffff;
const size34 = mask34 + 1;

const	intFixMax = mask7;
const	intFixMin = -32;

const	int8Max   = mask7;
const	int8Min   = -int8Max - 1;

const	int16Max  = mask15;
const	int16Min  = -int16Max - 1;

const	int32Max  = mask31;
const	int32Min  = -int32Max - 1;
