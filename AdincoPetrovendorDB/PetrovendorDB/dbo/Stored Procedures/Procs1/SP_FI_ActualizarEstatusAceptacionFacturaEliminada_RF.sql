-- =============================================
-- Author:		Alexander Gomez
-- Update date: 31-05-2019
-- Description: Modificación de la lógica de eliminación
-- =============================================
-- Author:		Daniel AC
-- Update date: 01-10-2020
-- Description: Se agrego eliminación de CO_Registro del lado de petrovendor y se corrigió eliminación de ta_tareas 
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ActualizarEstatusAceptacionFacturaEliminada_RF]
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,
    @IdUsuario INT,
    @IdAceptacionPedido INT,
    @Comentario NVARCHAR(MAX)
AS
BEGIN

    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    /*DATOS PARA EL REGISTRO DE ELIMINACION*/

    DECLARE @IDFACTURA INT;
    DECLARE @UUID NVARCHAR(100);
    DECLARE @IDFACTURAAD INT;
    DECLARE @IDFACTPETRO INT;
    DECLARE @TIPOELIMINACION NVARCHAR(10) = ('F');
    DECLARE @RESPONSE NVARCHAR(50) = N'FACTURA ELIMINADA';
    DECLARE @ELIMINADA BIT = 0;
    DECLARE @TA_OPERACION AS TABLE
    (
        IdOperacion INT NULL
    );
    DECLARE @COMENTARIO_INTERNO NVARCHAR(MAX);

    SELECT @IDFACTURA = IdFactura
    FROM dbo.MM_AceptacionFactura
    WHERE IdAceptacionPedido = @IdAceptacionPedido;

    SELECT @UUID = UUID
    FROM dbo.FI_Factura
    WHERE IdFactura = @IDFACTURA;

    SELECT @IDFACTURAAD = IdFactura
    FROM Adinco.dbo.FI_Factura
    WHERE UUID = @UUID;

    SELECT @IDFACTPETRO = IdFactura
    FROM dbo.FI_Factura
    WHERE UUID = @UUID;
	   
    /*OBTENER APROBACIÓN DE ACEPTACIÓN DE FACTURA ACTUAL*/
    /*HACER BIEN LA RELACIÓN YA QUE SI NO SE PUEDE ELIMINAR UNA APROBACIÓN DE MURPHY*/
    /*PARA ESO EN LAS OPERACIONES/APROBACIONES DE FACTURA SIEMPRE SE CARGA EL  IDPROVEEDOR DONDE ESTE ES IGUAL AL IdSubcontratista DE MM_PEDIDO*/

    INSERT INTO @TA_OPERACION
    (
        IdOperacion
    )
    SELECT O.IdOperacion
    FROM dbo.MM_AceptacionFactura AF
        JOIN dbo.TA_Operacion O
            ON AF.IdAceptacionFactura = O.IdDocumento
               AND O.IdTipoOperacion = 10 --> APROBACIÓN DE FACTURA 	
        JOIN dbo.MM_AceptacionPedido AP
            ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
        JOIN dbo.MM_Pedido P
            ON AP.IdPedido = P.IdPedido
               AND O.IdProveedor = P.IdSubcontratista --> ES EL PROVEEDOR QUE CARGA LA FACTURA 
    WHERE AF.IdAceptacionPedido = @IdAceptacionPedido;

    /*OBTENER HISTORIAL DE LA APROBACIÓN PARA GUARDARLO EN EL COMENTARIO INTERNO COMO HISTORIAL*/
    SELECT @COMENTARIO_INTERNO = (STUFF(
    (
        SELECT ',' + QUOTENAME(CONCAT(F.Descripcion, ':', FORMAT(F.Fecha, 'dd/MM/yyyy hh:mm tt')))
        FROM TA_HistorialFlujoTarea F
            JOIN @TA_OPERACION O
                ON F.IdOperacion = O.IdOperacion
        ORDER BY Fecha ASC
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'),
    1   ,
    1   ,
    ''
                                       )
                                 );

    SET @COMENTARIO_INTERNO = CONCAT(@Comentario,' Historial:', ISNULL(@COMENTARIO_INTERNO, ''));

    INSERT INTO dbo.AD_RegistroEliminacion
    (
        IdUsuario,
        FechaRegistro,
        ComentarioExterno,
        ComentarioInterno,
        TipoEliminacion,
        Activo,
        IdProveedor,
        IdContrato,
        IdProceso,
        Confirmacion
    )
    VALUES
    (   @IdUsuario,          -- IdUsuario - int
        GETDATE(),           -- FechaRegistro - dateti
        @Comentario,         -- ComentarioExterno - nvarchar(max)
        @COMENTARIO_INTERNO, -- ComentarioInterno - nvarchar(max)
        @TIPOELIMINACION,    -- TipoEliminacion - nvarchar(100)
        1,                   -- Activo - bit
        @IdProveedor,        -- IdProveedor -- int
        0,                   -- IdContrato -- int 
        @IdAceptacionPedido, -- IdProceso --int
        1                    --Confirmacion bit
        );

    DECLARE @IDELIMINACION INT =
            (
                SELECT @@IDENTITY
            );

    /*RESPALDO DE LA FACTURA DE ADINCO EN LAS TABLAS DE RESPALDO PR_FI...*/
    INSERT INTO dbo.PR_FI_CFDIConceptoImpuesto
    (
        IdFacturaConcepto,
        IdTipoImpuesto,
        NombreImpuesto,
        Base,
        Impuesto,
        TipoFactor,
        Tasa,
        Importe,
        IdEliminacion
    )
    SELECT IdFacturaConcepto,
           IdTipoImpuesto,
           NombreImpuesto,
           Base,
           Impuesto,
           TipoFactor,
           Tasa,
           Importe,
           @IDELIMINACION
    FROM Adinco.dbo.FI_CFDIConceptoImpuesto
    WHERE IdFacturaConcepto IN
          (
              SELECT CF.IdFacturaConcepto
              FROM Adinco.dbo.FI_CFDIConcepto AS CF
              WHERE CF.IdFactura = @IDFACTURAAD
          );

    DELETE Adinco.dbo.FI_CFDIConceptoImpuesto
    WHERE IdFacturaConcepto IN
          (
              SELECT CF.IdFacturaConcepto
              FROM Adinco.dbo.FI_CFDIConcepto AS CF
              WHERE CF.IdFactura = @IDFACTURAAD
          );

    INSERT INTO dbo.PR_FI_CFDIConcepto
    (
        IdFacturaConcepto,
        IdFactura,
        ClaveProdServ,
        Cantidad,
        ClaveUnidad,
        Unidad,
        Descripcion,
        ValorUnitario,
        Importe,
        NoIdentificacion,
        IdEliminacion
    )
    SELECT IdFacturaConcepto,
           IdFactura,
           ClaveProdServ,
           Cantidad,
           ClaveUnidad,
           Unidad,
           Descripcion,
           ValorUnitario,
           Importe,
           NoIdentificacion,
           @IDELIMINACION
    FROM Adinco.dbo.FI_CFDIConcepto
    WHERE IdFactura IN ( @IDFACTURAAD );

    DELETE Adinco.dbo.FI_CFDIConcepto
    WHERE IdFactura IN ( @IDFACTURAAD );

    INSERT INTO dbo.PR_FI_CFDIImpuesto
    (
        IdCFDIImpuesto,
        IdFactura,
        IdTipoImpuesto,
        Impuesto,
        TipoFactor,
        Tasa,
        Importe,
        IdEliminacion
    )
    SELECT IdCFDIImpuesto,
           IdFactura,
           IdTipoImpuesto,
           Impuesto,
           TipoFactor,
           Tasa,
           Importe,
           @IDELIMINACION
    FROM Adinco.dbo.FI_CFDIImpuesto
    WHERE IdFactura IN ( @IDFACTURAAD );

    DELETE Adinco.dbo.FI_CFDIImpuesto
    WHERE IdFactura IN ( @IDFACTURAAD );

    INSERT INTO dbo.PR_FI_Documento
    (
        IdDocumento,
        Documento,
        IdTipoDocumento,
        IdFactura,
        IdPedimentoComprobante,
        IdDocFacturacionSIPAC,
        NombreExtensionArchivo,
        IdUsuario,
        FechaCarga,
        IsEliminado,
        DocumentoByte,
        IdEliminacion
    )
    SELECT IdDocumento,
           Documento,
           IdTipoDocumento,
           IdFactura,
           IdPedimentoComprobante,
           IdDocFacturacionSIPAC,
           NombreExtensionArchivo,
           IdUsuario,
           FechaCarga,
           IsEliminado,
           DocumentoByte,
           @IDELIMINACION
    FROM Adinco.dbo.FI_Documento
    WHERE IdFactura IN ( @IDFACTURAAD )
          AND IdTipoDocumento = 1; --> ES TIPO FACTURA --> FI_TipoDocumento 

    DELETE Adinco.dbo.FI_Documento
    WHERE IdFactura IN ( @IDFACTURAAD )
          AND IdTipoDocumento = 1; --> ES TIPO FACTURA --> FI_TipoDocumento

    /*PROCESO DE ELIMINACIÓN EN ADINCO RESPALDO DE LOS ELIMINADO EN TABLAS PR(PAPELERA RECICLAJE) DE PETROVENDOR Y LUEGO ELIMINACION FISICA*/
    INSERT INTO dbo.PR_FI_ArchivoXml
    (
        ArchivoXml,
        HashSHA256,
        IdFactura,
        IdContrato,
        CreadoPor,
        CreadoEl,
        ModificadoPor,
        ModificadoEl,
        Activo,
        IdEliminacion
    )
    SELECT ArchivoXml,
           HashSHA256,
           IdFactura,
           IdContrato,
           CreadoPor,
           CreadoEl,
           ModificadoPor,
           ModificadoEl,
           Activo,
           @IDELIMINACION
    FROM Adinco.dbo.FI_ArchivoXml
    WHERE IdFactura IN ( @IDFACTURAAD );

    DELETE Adinco.dbo.FI_ArchivoXml
    WHERE IdFactura IN ( @IDFACTURAAD );

    --ELIMINACION DE GASTOS DE ADINCO
    DELETE Adinco.dbo.CO_Registro
    WHERE IdFactura IN ( @IDFACTURAAD );

    DELETE Adinco.dbo.FI_Transfer
    WHERE IdFacturaPago IN ( @IDFACTURAAD );

    DELETE Adinco.dbo.FI_TransferFactura
    WHERE IdFactura IN ( @IDFACTURAAD );

    --RESPALDO Y ELIMINACIÓN DE FACTURA DE PETROVENDOR 
    INSERT INTO dbo.PR_FI_Factura
    (
        IdFactura,
        Serie,
        Folio,
        Fecha,
        Sello,
        FormaPago,
        NoCertificado,
        Certificado,
        CondicionesDePago,
        SubTotal,
        Descuento,
        TipoCambio,
        Moneda,
        MontoConIva,
        TipoComprobante,
        MetodoPago,
        LugarExpedicion,
        NumCtaPago,
        Emisor,
        Receptor,
        UUID,
        FechaTimbrado,
        SelloCFD,
        NoCertificadoSAT,
        SelloSAT,
        Tipo,
        FechaRecepcion,
        IdSubcontratista,
        IdMoneda,
        IdContrato,
        XML,
        Activa,
        ArchivoPDF,
        ArchivoXML,
        CreadoPor,
        CreadoEn,
        ModificadoPor,
        ModificadoEn,
        --PDF,
        --IdReceptor,
        --IdentificadorSIPAC,
        NombreXML,
        IdEstudioPrecioTransfer,
        IdDocFacturacionSIPAC,
        ProcesadoSIPAC,
        --ClaveFormaPago,
        RegimenFiscal,
        UsoCFDI,
        VersionCFDI,
        --HashSHA256,
        --UUIDRelacionado,
        --TipoRelacion,
        --NoParcialidad,
        IdEliminacion
    )
    SELECT IdFactura,
           Serie,
           Folio,
           Fecha,
           Sello,
           FormaPago,
           NoCertificado,
           Certificado,
           CondicionesDePago,
           SubTotal,
           Descuento,
           TipoCambio,
           Moneda,
           MontoConIva,
           TipoComprobante,
           MetodoPago,
           LugarExpedicion,
           NumCtaPago,
           Emisor,
           Receptor,
           UUID,
           FechaTimbrado,
           SelloCFD,
           NoCertificadoSAT,
           SelloSAT,
           Tipo,
           FechaRecepcion,
           IdSubcontratista,
           IdMoneda,
           IdContrato,
           XML,
           Activa,
           ArchivoPDF,
           ArchivoXML,
           CreadoPor,
           CreadoEn,
           ModificadoPor,
           ModificadoEn,
           --PDF,
           --IdReceptor,
           --IdentificadorSIPAC,
           NombreXML,
           IdEstudioPrecioTransfer,
           IdDocFacturacionSIPAC,
           ProcesadoSIPAC,
           --ClaveFormaPago,
           RegimenFiscal,
           UsoCFDI,
           VersionCFDI,
           --HashSHA256,
           --UUIDRelacionado,
           --TipoRelacion,
           --NoParcialidad,
           @IDELIMINACION
    FROM Adinco.dbo.FI_Factura
    WHERE IdFactura IN ( @IDFACTURAAD );

	DELETE Adinco.dbo.FI_Factura
    WHERE IdFactura IN ( @IDFACTURAAD );

	--ELIMINACIÓN DE GASTOS DE PETROVENDOR
	DELETE dbo.CO_RelacionRegistroAdinco
	WHERE IdRegistroPetrovendor IN (SELECT IdRegistro FROM dbo.CO_Registro WHERE IdFactura=@IDFACTPETRO)

    DELETE dbo.CO_Registro
    WHERE IdFactura = @IDFACTPETRO;

	--ELIMINACION DE FACTURA EN PETROVENDOR

    DELETE dbo.FI_CFDIConcepto
    WHERE IdFactura IN ( @IDFACTPETRO );

    DELETE dbo.FI_CFDIImpuesto
    WHERE IdFactura IN ( @IDFACTPETRO );

    DELETE dbo.FI_Documento
    WHERE IdFactura IN ( @IDFACTPETRO )
          AND IdTipoDocumento = 1; --> ES TIPO FACTURA --> FI_TipoDocumento

    DELETE dbo.FI_RelacionArchivoXMLAdinco
    WHERE IdArchivoXML IN
          (
              SELECT IdArchivoXml FROM dbo.FI_ArchivoXml WHERE IdFactura = @IDFACTPETRO
          );

    DELETE dbo.FI_ArchivoXml
    WHERE IdFactura IN ( @IDFACTPETRO );

    DELETE dbo.FI_FacturaCompPagoRelacion
    WHERE IdFactura IN ( @IDFACTPETRO );

    DELETE dbo.FI_FacturaComplemento
    WHERE IdFactura IN ( @IDFACTPETRO );

    DELETE dbo.FI_Factura
    WHERE IdFactura IN ( @IDFACTPETRO );



    --ELIMINACION DE LA ACEPTACION DE  LA FACTURA Y DEL FLUJO DE APROBACIÓN JUNTO CON SUS TAREAS    

    DELETE dbo.TA_HistorialFlujoTarea
    WHERE IdOperacion IN
          (
              SELECT IdOperacion FROM @TA_OPERACION
          )
          AND IdEstadoFlujo != 1;

    DELETE dbo.TA_ComentariosTareaCancelada
    WHERE IdOperacion IN
          (
              SELECT IdOperacion FROM @TA_OPERACION
          );



    DELETE dbo.TA_TareaOperacion
    WHERE IdOperacion IN
          (
              SELECT IdOperacion FROM @TA_OPERACION
          );

    DELETE dbo.TA_Tarea
    WHERE IdOperacion IN
          (
              SELECT IdOperacion FROM @TA_OPERACION
          );


    DELETE dbo.TA_Operacion
    WHERE IdOperacion IN
          (
              SELECT IdOperacion FROM @TA_OPERACION
          );

    DELETE dbo.MM_AceptacionFactura
    WHERE IdAceptacionFactura IN
          (
              SELECT TOP 1
                     IdAceptacionFactura
              FROM dbo.MM_AceptacionFactura
              WHERE IdAceptacionPedido = @IdAceptacionPedido
          );


    IF
    (
        SELECT IdAceptacionFactura
        FROM dbo.MM_AceptacionFactura
        WHERE IdAceptacionPedido = @IdAceptacionPedido
    ) IS NOT NULL
    BEGIN

        SET @RESPONSE = N'ERROR AL ELIMINAR';

    END;

    IF @RESPONSE = 'FACTURA ELIMINADA'
    BEGIN
        SET @ELIMINADA = 1;
    END;

    SELECT @ELIMINADA;


END;
