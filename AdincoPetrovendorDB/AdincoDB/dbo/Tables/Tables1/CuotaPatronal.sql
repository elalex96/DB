CREATE TABLE CuotaPatronal(IdCuotaPatronal INT IDENTITY PRIMARY KEY, DocType NVARCHAR(500), Reverse NVARCHAR(100), Reclass NVARCHAR(100), RefDoc NVARCHAR(500), DocCurrency NVARCHAR(100), Concept NVARCHAR(500), CompanyCode NVARCHAR(100), PostingDate NVARCHAR(100), RequestedBy NVARCHAR(200), FiscalYear NVARCHAR(100), Period NVARCHAR(100), NombreArchivoImportado NVARCHAR(200), IdUsuario INT, IdContrato INT, FechaRegistro DATETIME default getdate(), 
FOREIGN KEY (IdUsuario) REFERENCES AP_USUARIO(UsuarioId), 
FOREIGN KEY (IdContrato) REFERENCES CO_CONTRATO(IdContrato))


