CREATE TABLE AP_BitacoraArchivos (
    Id INT PRIMARY KEY IDENTITY(1,1),  
    UsuarioId INT NOT NULL,            
    ContratoId INT NOT NULL,           
    ModuloId INT NOT NULL,             
    Fecha DATETIME NOT NULL,           
    Ruta NVARCHAR(500) NOT NULL,       
    Archivo NVARCHAR(255) NOT NULL,    
    AWSArchivoId NVARCHAR(255),        
    AWSIdentificador NVARCHAR(255),    
    Accion NVARCHAR(500) NOT NULL,
	FOREIGN KEY (ModuloId) REFERENCES Modulo(IdModulo)
);
