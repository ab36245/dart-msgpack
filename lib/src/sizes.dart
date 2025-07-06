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
