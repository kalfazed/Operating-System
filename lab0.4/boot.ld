SECTIONS
{
  . = 0x7c00;
  .text :
  {
    _ftext = . ; /*程序将装载到0x7c00*/
  } = 0

}
