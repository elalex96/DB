
-- =============================================
-- Author:		<DANIEL AC>
-- Create date: 01/10/2019
-- Description: Se  removio insertado de XML en Adinco 
-- =============================================

CREATE PROCEDURE [dbo].[CD_SP_EnvioXMLArchivoAdincoCompraDirecta]
    @idFacturaP INT,
    @idFacturaAdinco INT,
    /*--------------------parametros contrato  --------------------*/
    @IdContrato INT = NULL,
    @IdUsuario INT = NULL,
    @FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
BEGIN
    DECLARE @XMLAdinco INT,
            @XMLPetrovendor INT;

    -- Validar XML que no este en Adinco 

    DECLARE @CANTIDAD_XMLS INT;

    SELECT @CANTIDAD_XMLS = COUNT(IdArchivoXml)
    FROM Adinco.dbo.FI_ArchivoXml
    WHERE IdFactura = @idFacturaAdinco;


    IF ISNULL(@CANTIDAD_XMLS, 0) = 0
    BEGIN

        --Se copia el Archivo XML de la factura
        --INSERT INTO Adinco.dbo.FI_ArchivoXml
        --(
        --    ArchivoXml,
        --    HashSHA256,
        --    IdFactura,
        --    IdContrato,
        --    CreadoPor,
        --    CreadoEl,
        --    ModificadoPor,
        --    ModificadoEl,
        --    Activo
        --)
        --SELECT xmlP.ArchivoXml,
        --       xmlP.HashSHA256,
        --       @idFacturaAdinco,
        --       xmlP.IdContrato,
        --       xmlP.CreadoPor,
        --       xmlP.CreadoEl,
        --       xmlP.ModificadoPor,
        --       xmlP.ModificadoEl,
        --       xmlP.Activo
        --FROM Petrovendor.dbo.FI_ArchivoXml AS xmlP
        --WHERE xmlP.IdFactura = @idFacturaP;

        --SET @XMLAdinco = @@IDENTITY;
		INSERT INTO dbo.BitacoraErrores
		(
		    HResult,
		    Mensaje,
		    StackTrace,
		    IdUsuario,
		    IdProveedor,
		    FechaRegistro
		)
		VALUES
		(   0,        -- HResult - int
		    CONCAT('No se ha encontrado XML de Adinco de la factura ', @IdFacturaAdinco, ' factura en petrovendor ', @idFacturaP),     -- Mensaje - nvarchar(max)
		    N'',      -- StackTrace - nvarchar(max)
		    @IdUsuario,        -- IdUsuario - int
		    0,        -- IdProveedor - int
		    GETDATE() -- FechaRegistro - datetime
		)
    END;

    ELSE
    BEGIN
        SELECT @XMLAdinco = IdArchivoXml
        FROM Adinco.dbo.FI_ArchivoXml
        WHERE IdFactura = @idFacturaAdinco;

    END;

    ---Validar que no exista la relación 
    DECLARE @EXISTE_RELACION INT;

    SELECT @EXISTE_RELACION = COUNT(IdRelacionArchivoXMLAdinco)
    FROM FI_RelacionArchivoXMLAdinco
    WHERE IdArchivoXML = @XMLPetrovendor
          AND IdArchivoXMLAdinco = @XMLAdinco;

    IF ISNULL(@EXISTE_RELACION, 0) = 0
    BEGIN

        SELECT @XMLPetrovendor = IdArchivoXml
        FROM dbo.FI_ArchivoXml
        WHERE IdFactura = @idFacturaP;

        INSERT INTO dbo.FI_RelacionArchivoXMLAdinco
        (
            IdArchivoXML,
            IdArchivoXMLAdinco,
			CreadoEl,
			Observacion
        )
        VALUES
        (   @XMLPetrovendor, -- IdArchivoXML - int
            @XMLAdinco,       -- IdArchivoXMLAdinco - int
			GETDATE(),
			''
        );
    END;
    ELSE
    BEGIN

        DECLARE @DETALLE NVARCHAR(MAX) = CONCAT('INTENTO:', CAST(GETDATE() AS NVARCHAR(200)), '. ');

        UPDATE dbo.FI_RelacionArchivoXMLAdinco
        SET Observacion = CONCAT(ISNULL(Observacion, ''), @DETALLE),
            EditadoEl = GETDATE()
        WHERE IdArchivoXML = @XMLPetrovendor
              AND IdArchivoXMLAdinco = @XMLAdinco;

    END;

END;
