public class WrapperUIElementHeader extends  WrapperUIGridElemnt {

public override virtual String toString()
    {
        String[] returnValue =new String [0];
        
          returnValue.add('<WrapperUIElementHeader>');
        returnValue.add('<name>' + name);
        returnValue.add('</name>');
         returnValue.add('<style>' + this.getStyle());
        returnValue.add('</style>');
          returnValue.add('</WrapperUIElementHeader>');
        String returnValueStr= String.join(returnValue, '');
        return returnValueStr;
    }

}