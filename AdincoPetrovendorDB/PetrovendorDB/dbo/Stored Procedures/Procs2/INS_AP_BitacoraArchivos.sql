USE Petrovendor
GO
DROP PROC IF EXISTS INS_AP_BitacoraArchivos
GO
CREATE PROC INS_AP_BitacoraArchivos
    @UsuarioId INT,
    @ContratoId INT,
    @Ruta NVARCHAR(500),
    @Archivo NVARCHAR(255),
    @AWSArchivoId NVARCHAR(255) = NULL,  -- Parámetro para el ID del archivo en AWS (opcional)
    @AWSIdentificador NVARCHAR(255) = NULL, -- Parámetro para el identificador adicional de AWS (UUID) 
    @Accion NVARCHAR(500)            
AS
BEGIN
	-- Se obtiene el módulo id a partir de la ruta de descarga
	DECLARE @ModuloId int = (SELECT top 1 IdModulo FROM Modulo where URL_MODULO = @Ruta);
    INSERT INTO AP_BitacoraArchivos 
    (
        UsuarioId, 
        ContratoId, 
        ModuloId, 
        Fecha, 
        Ruta, 
        Archivo, 
        AWSArchivoId, 
        AWSIdentificador, 
        Accion
    )
    VALUES 
    (
        @UsuarioId, 
        @ContratoId, 
        @ModuloId, 
        GETDATE(), 
        @Ruta, 
        @Archivo, 
        @AWSArchivoId, 
        @AWSIdentificador, 
        @Accion
    );
END
GO
