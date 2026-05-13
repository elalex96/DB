

CREATE PROCEDURE [dbo].[sp_FI_InsertaArchivoXmlParaPruebas]
    -- Add the parameters for the stored procedure here
    @ArchivoXml IMAGE,
    @Hash256 NVARCHAR(MAX),
    @IdOper INT,
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @count INT;
    SELECT @count = COUNT(1)
      FROM FI_ArchivoXml
     WHERE IdFactura = @IdOper;
    IF @count >= 1
    BEGIN
        UPDATE FI_ArchivoXml
           SET ArchivoXml = @ArchivoXml,
               HashSHA256 = @Hash256,
               IdContrato = @IdContrato,
               ModificadoPor = @IdUsuario,
               ModificadoEl = GETDATE()
         WHERE IdFactura = @IdOper;
    END;
    ELSE
    BEGIN
        INSERT INTO FI_ArchivoXml (ArchivoXml,
                                   HashSHA256,
                                   IdFactura,
                                   IdContrato,
                                   CreadoPor,
                                   CreadoEl,
                                   Activo)
        VALUES (@ArchivoXml, @Hash256, @IdOper, @IdContrato, @IdUsuario, GETDATE(), 1);

        --Devuelve error o no
        IF @@ERROR <> 0
            SELECT 'false' AS msj;
        ELSE
            SELECT 'true' AS msj;
    END;
END;