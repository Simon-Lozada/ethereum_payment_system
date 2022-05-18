// SPDX-License-Identifier: MIT

pragma solidity > 0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract Disney{
    
    //// _____________ DECLARACIONES INICIALES _____________ ////

    //Instacia del contacto token
    ERC20Basic private token;

    //Direccion de Disney (owner)
    address payable public owner;

    //Constructor
    constructor() public {
        token = new ERC20Basic(10000);
        owner = msg.sender;
    }

    //Estructura de datos para almacenar a los clientes de Disney
    struct cliente {
        uint tokens_comprados;
        string [] atracciones_disfrutadas;
    }

    //Mapping para le registro de clientes
    mapping (address => cliente) public Clientes;

    //Funcion para establecer el precio de un Token
    function precioTokens(uint _numTokens) internal pure returns(uint){
        //Convertimos para establecer el precio de un token
        return _numTokens*(1 ether);
    }
    
    //Funcion para comprar tokens en disney y disfrutar de las atracciones
    function CompraTokens(uint _numTokens) public payable{
        //Establecer el precio de los tokens
        uint coste = precioTokens(_numTokens);
        //Se evalua el dinero que el cliente paga por los tokens
        require(msg.value >= coste, "Compra menos Tokens o paga can mas ethers");
        //Diferencia de lo que el cliente paga
        uint returnValue = msg.value - coste;
        //Disney retorna la cantidad de ethers al cliente
        msg.sender.transfer(returnValue);
        //Obtencion del numero de tokens disponibles
        uint balance = balanceOf();
        require(_numTokens <= balance, "Compra un numero menor de tokens");
        //Se transfiere el numero de tokens disponibles
        token.transfer(msg.sender, _numTokens);
        //Registro de tokens comprados
        Clientes[msg.sender].tokens_comprados = _numTokens;

    }

    // Balance de tokens del contrato disney
    function balanceOf() public view returns (uint) {
        return token.balanceOf(address(this));
    }

    //visualizar el numero de tokens restantes de un cliente
    function MisTokens() public view returns(uint){
        return token.balanceOf(msg.sender);
    }

    //Funcion para generar mas tokens
    function GeneraTokens(uint _numTokens) public Unicamente(msg.sender){
        token.increaseTotalSupply(_numTokens);
    }

    //Modificar para controlar las funciones ejecutables por disney
    modifier Unicamente(address _direccion){
        require(_direccion == owner, "No tines permisos para ejecutar esta funcion");
        // el "_;" pararece ser un requisito de los modifier
        _;
    }
    //// _____________ GESTION DE DISNEY _____________ ////
//// _____________ GESTION DE DISNEY (Atraciones) _____________ ////

    //Eventos
    event disfruta_atraccion(string, uint, address);
    event nueva_atraccion(string, uint);
    event baja_atraccion(string);
    
    // Estructura de la atraccion 
    struct atraccion {
        string nombre_atraccion;
        uint precio_atraccion;
        bool estado_atraccion;
    }
    
    // Mapping para relacion un nombre de una atraccion con una estructura de datos de la atraccion
    mapping (string => atraccion) public MappingAtracciones;

    //Array para almacenar el nombre de la atracciones
    string [] Atracciones;

    // Mapping para relacionar una identidad (cliente) con su historial de atracciones en DISNEY
    mapping (address => string []) HistorialAtracciones;

    // Star Wars -> 2 tokens
    // Toy Story -> 5 tokens
    // Piratas del caribe -> 8 tokens
    
    // Crear nuevas atracciones para DISNEY (SOLO es ejecutable por Disney)
    function NuevaAtraccion(string memory _nombreAtraccion, uint _precio) public Unicamente (msg.sender) {
        // Creacion de una atraccion en Disney 
        MappingAtracciones[_nombreAtraccion] = atraccion(_nombreAtraccion,_precio, true);
        // Almacenamiento en un array el nombre de la atraccion 
        Atracciones.push(_nombreAtraccion);
        // Emision del evento para la nueva atraccion 
        emit nueva_atraccion(_nombreAtraccion, _precio);
    }

    //Dar baja a una atraccion de Disney
    function BajaAtraccion(string memory _nombreAtraccion) public Unicamente(msg.sender){
        //El estado de la atraccion pasa a FALSE => No esta en uso
        MappingAtracciones[_nombreAtraccion].estado_atraccion = false;
        //Emision del evento para la baja de la atraccion
        emit baja_atraccion(_nombreAtraccion);
    }

    // Visualizar las atracciones de Disney 
    function AtraccionesDisponibles() public view returns (string [] memory){
        return Atracciones;
    }


    // Funcion para subirse a una atraccion de disney y pagar en tokens 
    function SubirseAtraccion (string memory _nombreAtraccion) public {
        // Precio de la atraccion (en tokens)
        uint tokens_atraccion = MappingAtracciones[_nombreAtraccion].precio_atraccion;
        // Verifica el estado de la atraccion (si esta disponible para su uso)
        require (MappingAtracciones[_nombreAtraccion].estado_atraccion == true, 
                    "La atraccion no esta disponible en estos momentos.");
        // Verifica el numero de tokens que tiene el cliente para subirse a la atraccion 
        require(tokens_atraccion <= MisTokens(), 
                "Necesitas mas Tokens para subirte a esta atraccion.");
        
        /* El cliente paga la atraccion en Tokens:
        - Ha sido necesario crear una funcion en ERC20.sol con el nombre de: 'transferencia_disney'
        debido a que en caso de usar el Transfer o TransferFrom las direcciones que se escogian 
        para realizar la transccion eran equivocadas. Ya que el msg.sender que recibia el metodo Transfer o
        TransferFrom era la direccion del contrato.
        */
        token.transferencia_disney(msg.sender, address(this),tokens_atraccion);
        // Almacenamiento en el historial de atracciones del cliente 
        HistorialAtracciones[msg.sender].push(_nombreAtraccion);
        // Emision del evento para disfrutar de la atraccion 
        emit disfruta_atraccion(_nombreAtraccion, tokens_atraccion, msg.sender);
    }


    //Visualizar el historial del cliente
    function Historial() public view returns(string[] memory){
        return HistorialAtracciones[msg.sender];
    }

//// _____________ GESTION DE DISNEY (Comidas) _____________ ////
        
    //Eventos
    event disfruta_comida(string, uint, address);
    event nueva_comida(string, uint);
    event baja_comida(string);
    
    // Estructura de la Comida 
    struct comida {
        string nombre_comida;
        uint precio_comida;
        bool estado_comida;
    }
    
    // Mapping para relacion un nombre de una Comidas con una estructura de datos de la Comida
    mapping (string => comida) public MappingComidas;

    //Array para almacenar el nombre de la Comidas
    string [] Comidas;

    // Mapping para relacionar una identidad (cliente) con su historial de Comidas en DISNEY
    mapping (address => string []) HistorialComidas;

    // Star Wars -> 2 tokens
    // Toy Story -> 5 tokens
    // Piratas del caribe -> 8 tokens
    
    // Crear nuevas Comidas para DISNEY (SOLO es ejecutable por Disney)
    function NuevaComidas(string memory _nombreComidas, uint _precio) public Unicamente (msg.sender) {
        // Creacion de una Comida en Disney 
        MappingComidas[_nombreComidas] = comida(_nombreComidas,_precio, true);
        // Almacenamiento en un array el nombre de la Comida 
        Comidas.push(_nombreComidas);
        // Emision del evento para la nueva Comida 
        emit nueva_comida(_nombreComidas, _precio);
    }

    //Dar baja a una Comida de Disney
    function BajaComidas(string memory _nombreComidas) public Unicamente(msg.sender){
        //El estado de la Comida pasa a FALSE => No esta en uso
        MappingComidas[_nombreComidas].estado_comida = false;
        //Emision del evento para la baja de la Comida
        emit baja_comida(_nombreComidas);
    }

    // Visualizar las Comidas de Disney 
    function ComidasDisponibles() public view returns (string [] memory){
        return Comidas;
    }


    // Funcion para subirse a una Comida de disney y pagar en tokens 
    function ComerComidas (string memory _nombreComidas) public {
        // Precio de la Comida (en tokens)
        uint tokens_comida = MappingComidas[_nombreComidas].precio_comida;
        // Verifica el estado de la Comida (si esta disponible para su uso)
        require (MappingComidas[_nombreComidas].estado_comida == true, 
                    "La Comida no esta disponible en estos momentos.");
        // Verifica el numero de tokens que tiene el cliente para subirse a la Comida 
        require(tokens_comida <= MisTokens(), 
                "Necesitas mas Tokens para tener a esta comida.");
        
        /* El cliente paga la Comida en Tokens:
        - Ha sido necesario crear una funcion en ERC20.sol con el nombre de: 'transferencia_disney'
        debido a que en caso de usar el Transfer o TransferFrom las direcciones que se escogian 
        para realizar la transccion eran equivocadas. Ya que el msg.sender que recibia el metodo Transfer o
        TransferFrom era la direccion del contrato.
        */
        token.transferencia_disney(msg.sender, address(this),tokens_comida);
        // Almacenamiento en el historial de Comidas del cliente 
        HistorialComidas[msg.sender].push(_nombreComidas);
        // Emision del evento para disfrutar de la Comida 
        emit disfruta_comida(_nombreComidas, tokens_comida, msg.sender);
    }


    //Visualizar el historial del cliente

    function HistorialComida() public view returns (string [] memory) {
        return HistorialComidas[msg.sender];
    }



/////////////////////////////////////////////////////////////////////////


    //Funcion para que un cliente de Disney pueda devolver Tokens
    function DevolverTokens (uint _numTokens) public payable {
        //El numero de tokens a devolver es positivo
        require(_numTokens > 0, "Necesitas devolver una cantidad positiva de tokens.");
        //El cliente devuelve los tokens
        token.transferencia_disney(msg.sender, address(this), _numTokens);
        //Devolucion de los ethers al cliente
        msg.sender.transfer(precioTokens(_numTokens));
    }


}