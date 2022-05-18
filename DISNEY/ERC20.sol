// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";

//cuentas ejemplos:
//Juan Gabriel --> 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
//Juna Amegual --> 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
//Maria Santos --> 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db


//Interface de nuestro token ERC20
interface IERC20{
    ////    METODOS DE TOKEN    ////
    // devuelve la cantidad de tokes en exsistencia
    function totalSupply() external view returns(uint256);

    // devuelve la cantidad de tokens para cada direccion indicada por parámetros
    function balanceOf(address account) external view returns (uint256);
    
    // devuelve el número de tokens que el gastador(spender) podrá gastar en nombre del propietario (owner)
    function allowance(address owner, address spender) external view returns(uint256);

    ////   METODOS ADICIONALES  ////
    // devuelve un valor booleano resultando de la operación indicada
    function transfer(address receiver, uint256 amount) external returns(bool);

    //devuelve un valor booleano resultando de la operación indicada
    function transferencia_disney(address _cliente, address recipient, uint256 amount) external returns (bool);

    // devuelve un valor booleano con el resultado de la operción de gasto
    function approve(address spender, uint256 amount) external returns(bool);

    // devuelve un valor booleano con el resultado de la operación de paso de una cantidad de tokens usando el método allowance()
    function transferFrom(address sender, address receiver, uint256 amount) external returns (bool);

    ////  EVENTOS DE NOTIFICACION ////
    // evento que se debe emitir cuendo una cantidad de tokes pase de un origen a un destino
    event Transfer(address indexed from, address indexed to, uint256 value);

    // evento que se debe imitír cunado se establece una asignación con el método allopwance
    event Approval(address indexed owner, address indexed totalSupply, uint256 value);

}

//Implementacion de los funciones ERC20
contract ERC20Basic is IERC20{

    string public constant name = "ERC20BlockchainAZ";
    string public constant symbol = "ERC";
    uint8 public constant decimal = 2;

    ////  EVENTOS DE NOTIFICACION ////

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed owner, address indexed toltalSupply, uint256 tokes);

    using SafeMath for uint256;
    
    // mapaiamos la ubicacion de los tokens por cuneta
    mapping (address => uint) balances;
    // mapaiamos la ubicacion de los tokens por cuneta y las transferencias entre ellas
    mapping (address => mapping (address => uint)) allowed;
    // decimos la cantidad maxima de tokes en exsistencia
    uint totalSupply_;

    //Creamos una cantidad inicial de tokens
    constructor (uint256 initialSupply) public{
        //decimos que la cantidad total de tokens es igual a la cantidad inicial
        totalSupply_ = initialSupply;
        
        //le damos la cantidad total de tokens a un cuenta
        balances[msg.sender] = totalSupply_;
    }

    ////    METODOS DE TOKEN    ////
    function totalSupply() public override view returns (uint256){
        return totalSupply_;
    }

    function increaseTotalSupply(uint newTokensAmount) public {
        // le sumamos los nuevos tokens creados a totalSupply_ local(cantidad de tokens total de la red)
        totalSupply_ +=  newTokensAmount;
        
        // le damos los nuevos tokens a quien a enviado el mesaje de incrementar el numeros de tokens(minero)
        balances[msg.sender] +=  newTokensAmount;
    }
   
    function balanceOf(address tokenOwner) public override view returns (uint256){
        return balances[tokenOwner];
    }
    
    function allowance(address owner, address delegate) public override view returns (uint256){
        // hacemos un mapiado (usando allowance) de todas las direcciones que tiene repartidad la cantidad toltal de tokens del poseedor final(owner) y vemos cuanta cantidad de tokes corres ponde a la dirrecion del "delagado"(delegate) 
        return allowed[owner][delegate];
    }

    ////   METODOS ADICIONALES  ////
    function transfer(address receiver, uint256 numTokens)  public override returns(bool){
        //Aqui ponesmos como requisito que el balance de cuenta del emisor del mensaje se igual o mayor que los tokens que quiere eviar
        require(numTokens <= balances[msg.sender]);

        //IMPORTANTE SIEMPRE HACER LA RESTA PRIMERO QUE LA SUMA PARA EVITAR CREAR INFLACION ARTIFICAL POR FALLAS DEL SISTEMA
        //Restamos un determinado numero de tokens de la cuenta de quien envio el mesaje
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        
        //sumamos un determinado numero de tokens a la cuenta de quien recive el mensaje      
        balances[receiver] = balances[receiver].add(numTokens);
        
        //Notificamos a toda la red sobre la transferencia de tokens ocurrida
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }
    function transferencia_disney(address _cliente, address receiver, uint256 numTokens) public override returns(bool){
        //Aqui ponesmos como requisito que el balance de cuenta del emisor del mensaje se igual o mayor que los tokens que quiere eviar
        require(numTokens <= balances[_cliente]);

        //IMPORTANTE SIEMPRE HACER LA RESTA PRIMERO QUE LA SUMA PARA EVITAR CREAR INFLACION ARTIFICAL POR FALLAS DEL SISTEMA
        //Restamos un determinado numero de tokens de la cuenta de quien envio el mesaje
        balances[_cliente] = balances[_cliente].sub(numTokens);
        
        //sumamos un determinado numero de tokens a la cuenta de quien recive el mensaje      
        balances[receiver] = balances[receiver].add(numTokens);
        
        //Notificamos a toda la red sobre la transferencia de tokens ocurrida
        emit Transfer(_cliente,receiver,numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns(bool){
        //El emisor(msg.sender) delega a el receptor(delegate) la cantidad numTokens
        allowed[msg.sender][delegate] = numTokens;
        
        //Informamos a la red que el emisor(msg.sender) ha aporovado(Approval) delegado(delegate) a usar la cantidad numTokens
        emit Approval(msg.sender, delegate, numTokens);
        
        return true;
    }


    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool){
        //Verificamos si el propietario de los tokens tiene la cantidad pedida para transferirlos
        require(numTokens <= balances[owner]);
        //Verificamos si el delagado tiene la autoriacion para mover la cantidad de tokens requerida
        require(numTokens <= allowed[owner][msg.sender]);
        
        //IMPORTANTE PRIMERO QUITAR EL DINERO DE LA CUETA PARA EVITAR INFLACION ARTIFICAL
        //le restamos la cantidad de tokens(numTokens) al balance(cuneta) del dueño(owner)
        balances[owner] = balances[owner].sub(numTokens);
        //le restamos al delegado la autoridad de mover la catidad de tokens(numTokens)
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        //le sumamos al balance(cuneta) del comprador la cantidad de tokens
        balances[buyer] = balances[buyer].add(numTokens);
        //infromamos a la red sobre la transacion (owner-numTokens, buyer+numTokens)
        emit Transfer(owner, buyer, numTokens);
        return true;
    }


}