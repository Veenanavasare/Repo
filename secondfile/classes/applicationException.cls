public virtual class applicationException extends Exception {
public String msgId;
public String msg;
Exception e;

public applicationException (String id,String m){
//super(id,m);
msgId=id;
msg=m;
}
public applicationException (String id,String m,Exception e1){
//super(id,m);
msgId=id;
msg=m;
e=e1;

}
public virtual String toString (){
String[] s= new String[0];
s.add(msgId);
s.add(msg);
s.add(''+e);

if(e!=null){
s.add(''+e.getStackTraceString());
}
return ''+s;

}
}