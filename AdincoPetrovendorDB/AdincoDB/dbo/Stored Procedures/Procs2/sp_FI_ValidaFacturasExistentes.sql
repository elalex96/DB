CREATE PROCEDURE dbo.sp_FI_ValidaFacturasExistentes
    @UUID VARCHAR(500),
    @idContrato INT = 3,
    @idUsuario INT = 1
AS
BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Validación de facturas existentes
-- =============================================
-- BAAC	20190731	Se modifica para validar solo si ya existe la factura en Adinco
-- =============================================
SET NOCOUNT ON

DECLARE @Existe INT = 0

SELECT @Existe = COUNT(1) 
FROM FI_FACTURA 
WHERE UUID = @UUID

SELECT @Existe AS Existe

    /*DECLARE @Existe NVARCHAR(MAX) = '',
            @Count  INT;

    SELECT @Count = COUNT(*)
      --SELECT *
      FROM dbo.FI_Factura
     WHERE UUID = @UUID;
    IF (@Count > 0)
    BEGIN
        SELECT @Existe = 'La factura con folio: '+ F.Folio+' y UUID: '+@UUID+', ya se encuentra registrada en Adinco, en el contrato: ' + c.NumeroContrato
          --SELECT *
          FROM dbo.FI_Factura f
          JOIN CO_Contrato c
            ON c.IdContrato = f.IdContrato
         WHERE UUID = @UUID;
    --'52BF96BE-F6DF-4D6E-BC4F-DE141634F409';
    END;
    ELSE
    BEGIN
        SELECT @Count = COUNT(*)
        --SELECT      *
          FROM      Petrovendor.dbo.MM_AceptacionFactura AF
         INNER JOIN Petrovendor.dbo.FI_Factura F
            ON AF.IdFactura  = F.IdFactura
         INNER JOIN Petrovendor.dbo.TA_Operacion T
            ON T.IdDocumento = AF.IdAceptacionFactura
         INNER JOIN Petrovendor.dbo.TA_Estatus E
            ON E.IdEstatus   = T.IdEstatusOperacion
         WHERE      UUID = @UUID
           AND      F.Activa  = 1;

        IF (@Count > 0)
        BEGIN
            SELECT      @Existe = 'La factura con folio: '+ F.Folio+' y UUID: '+@UUID+', ya ha sido ingresada anteriormente desde el modulo de procura y se encuentra: ' + E.Nombre
              FROM      Petrovendor.dbo.MM_AceptacionFactura AF
             INNER JOIN Petrovendor.dbo.FI_Factura F
                ON AF.IdFactura  = F.IdFactura
             INNER JOIN Petrovendor.dbo.TA_Operacion T
                ON T.IdDocumento = AF.IdAceptacionFactura
             INNER JOIN Petrovendor.dbo.TA_Estatus E
                ON E.IdEstatus   = T.IdEstatusOperacion
             WHERE      UUID = @UUID
               AND      F.Activa  = 1 AND F.IsEliminado=0;
        END;

    --SELECT uuid FROM Petrovendor.dbo.FI_Factura WHERE IdFactura=18562
    END;

    SELECT @Existe AS error;
	*/
END

