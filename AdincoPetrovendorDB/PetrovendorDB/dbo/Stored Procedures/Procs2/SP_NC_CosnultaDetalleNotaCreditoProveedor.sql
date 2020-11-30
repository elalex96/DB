-- =============================================  
-- Author:  Alexander Gomez  
-- Create date: 23/09/2019  
-- Description: Consulta de detalles de la nota de credito desde el proveedor  
-- =============================================  
-- =============================================  
-- Author:  Daniel AC
-- Create date: 13/10/2020  
-- Description: Se actualizo sp, se cambio tipo Datatime a VARCHAR(MAX)
-- =============================================  
CREATE PROCEDURE SP_NC_CosnultaDetalleNotaCreditoProveedor
    -- Add the parameters for the stored procedure here  
    @IdProveedor INT,
    @IdAceptacionPedido INT,
    @IdNoNotaCredito INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from  
    -- interfering with SELECT statements.  
    SET NOCOUNT ON;
    CREATE TABLE #tempselect
    (
        IdAceptacionNotaCredito INT,
        ComprobantePDFByte IMAGE,
        ComprobanteXMLByte IMAGE,
        Descripcion VARCHAR(MAX),
        Estatus VARCHAR(MAX),
        CreadoEl VARCHAR(MAX),
        Nombre VARCHAR(MAX),
        IdFactura INT,
        Subtotal MONEY,
        MonedaFacturaNotaCredito VARCHAR(MAX),
        MontoConIva DECIMAL,
        IdOperacion INT,
        FechaModificacion VARCHAR(MAX),
        ComentarioAprobador VARCHAR(MAX),
        Moneda VARCHAR(200),
        NombreFlujo VARCHAR(MAX),
        DetalleFlujo VARCHAR(MAX),
        NombreTipoFlujo VARCHAR(MAX),
        IdEstatusEliminada INT,
        IdEliminado INT,
        FechaRegistro VARCHAR(MAX),
        ComentarioExterno VARCHAR(MAX),
        ComentarioInterno VARCHAR(MAX),
        NombreArchivo VARCHAR(MAX),
        Proveedor VARCHAR(MAX),
        MonedaAceptacion VARCHAR(200),
        CFDIRelacionados VARCHAR(MAX),
        IdAceptacionPedido INT,
        IdEstatusOperacion INT,
        UUID VARCHAR(MAX)
    );

    -------  
    INSERT INTO #tempselect
    (
        IdAceptacionNotaCredito,
        ComprobantePDFByte,
        ComprobanteXMLByte,
        Descripcion,
        Estatus,
        CreadoEl,
        Nombre,
        IdFactura,
        Subtotal,
        MonedaFacturaNotaCredito,
        MontoConIva,
        IdOperacion,
        FechaModificacion,
        ComentarioAprobador,
        Moneda,
        NombreFlujo,
        DetalleFlujo,
        NombreTipoFlujo,
        IdEstatusEliminada,
        IdEliminado,
        FechaRegistro,
        ComentarioExterno,
        ComentarioInterno,
        NombreArchivo,
        Proveedor,
        MonedaAceptacion,
        CFDIRelacionados,
        IdAceptacionPedido,
        IdEstatusOperacion,
        UUID
    )
    SELECT NC.IdAceptacionNotaCredito,
           F.ComprobantePDFByte,
           F.ComprobanteXMLByte,
           'Sin Descripcion' AS Descripcion,
           E.Nombre AS Estatus,
           FORMAT(NC.CreadoEl, 'dd/MM/yyyy hh:mm tt') AS CreadoEl,
           UC.Nombre AS CargadoPor,
           F.IdFactura,
           F.SubTotal,
           '' AS MonedaFacturaNotaCredito,
           F.MontoConIva,
           '0' AS IdOperacion,
           CAST(ISNULL(FORMAT(GETDATE(), 'dd/MM/yyyy hh:mm tt'), 'N/A') AS NVARCHAR(MAX)) AS FechaCambioEstatus,
           '' AS ComentarioAprobador,
           F.Moneda,
           '' AS NombreFlujo,
           '' AS DetalleFlujo,
           '' AS NombreTipoFlujo,
           ISNULL(NC.IdEstatusEliminada, 0) AS IdEstatusEliminada,
           NC.IdEliminado,
           FORMAT(RE.FechaRegistro, 'dd/MM/yyyy hh:mm tt') AS FechaRegistro,
           RE.ComentarioExterno,
           RE.ComentarioInterno,
           CONCAT('Nota crédito No. ', CAST(NC.IdAceptacionNotaCredito AS NVARCHAR(MAX))) AS NombreArchivo,
           PV.RazonSocial AS Proveedor,
           po.Currency,
           NC.CFDIRelacionados,
           NC.IdAceptacionPedido,
           0 AS IdEstatusOperacion,
           F.UUID
    FROM MPY_MM_AceptacionNotaCredito AS NC
        JOIN FI_Factura AS F
            ON NC.IdFacturaNotaCredito = F.IdFactura
        JOIN TA_Estatus AS E
            ON NC.IdEstatus = E.IdEstatus
        JOIN S_Usuario AS UC
            ON NC.CreadoPor = UC.IdUsuario
        LEFT JOIN dbo.AD_RegistroEliminacion RE
            ON NC.IdEliminado = RE.IdEliminacion
        JOIN S_Proveedor AS PV
            ON PV.IdProveedor = @IdProveedor
        JOIN MPY_MM_AceptacionPedido AS ap
            ON NC.IdAceptacionPedido = ap.IdAceptacionPedido
        JOIN Adinco..CO_SAPPO AS po
            ON ap.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = po.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS
    WHERE NC.IdAceptacionNotaCredito = @IdNoNotaCredito
          AND NC.IdAceptacionPedido = @IdAceptacionPedido;


    -- Insert statements for procedure here  
    INSERT INTO #tempselect
    (
        IdAceptacionNotaCredito,
        ComprobantePDFByte,
        ComprobanteXMLByte,
        Descripcion,
        Estatus,
        CreadoEl,
        Nombre,
        IdFactura,
        Subtotal,
        MonedaFacturaNotaCredito,
        MontoConIva,
        IdOperacion,
        FechaModificacion,
        ComentarioAprobador,
        Moneda,
        NombreFlujo,
        DetalleFlujo,
        NombreTipoFlujo,
        IdEstatusEliminada,
        IdEliminado,
        FechaRegistro,
        ComentarioExterno,
        ComentarioInterno,
        NombreArchivo,
        Proveedor,
        MonedaAceptacion,
        CFDIRelacionados,
        IdAceptacionPedido,
        IdEstatusOperacion,
        UUID
    )
    SELECT NC.IdAceptacionNotaCredito,
           F.ComprobantePDFByte,
           F.ComprobanteXMLByte,
           O.Descripcion,
           E.Nombre AS Estatus,
           FORMAT(NC.CreadoEl, 'dd/MM/yyyy hh:mm tt') AS CreadoEl,
           UC.Nombre AS CargadoPor,
           F.IdFactura,
           F.SubTotal,
           TMF.TipoMonedaCorto AS MonedaFacturaNotaCredito,
           F.MontoConIva,
           O.IdOperacion,
           CAST(ISNULL(FORMAT(O.FechaModificacion, 'dd/MM/yyyy hh:mm tt'), 'N/A') AS NVARCHAR(MAX)) AS FechaCambioEstatus,
           '' AS ComentarioAprobador,
           F.Moneda,
           FT.Nombre AS NombreFlujo,
           FT.Descripcion AS DetalleFlujo,
           TFT.Nombre AS NombreTipoFlujo,
           ISNULL(NC.IdEstatusEliminada, 0) AS IdEstatusEliminada,
           NC.IdEliminado,
           FORMAT(RE.FechaRegistro, 'dd/MM/yyyy hh:mm tt') AS FechaRegistro,
           RE.ComentarioExterno,
           RE.ComentarioInterno,
           CONCAT('Nota crédito No. ', CAST(NC.IdAceptacionNotaCredito AS NVARCHAR(MAX))) AS NombreArchivo,
           PV.RazonSocial AS Proveedor,
           TM.TipoMonedaCorto AS MonedaAceptacion,
           NC.CFDIRelacionados,
           NC.IdAceptacionPedido,
           O.IdEstatusOperacion,
           F.UUID
    FROM dbo.MM_AceptacionNotaCredito NC
        JOIN dbo.MM_AceptacionPedido AP
            ON NC.IdAceptacionPedido = AP.IdAceptacionPedido
        JOIN dbo.MM_Pedido P
            ON AP.IdPedido = P.IdPedido
        JOIN dbo.PV_TipoMoneda TM
            ON P.IdMoneda = TM.IdMoneda
        JOIN dbo.TA_Operacion O
            ON NC.IdAceptacionNotaCredito = O.IdDocumento
               AND O.IdTipoOperacion = 17 --> APROBACIÓN NOTA DE CREDITO  
        JOIN dbo.TA_Estatus E
            ON O.IdEstatusOperacion = E.IdEstatus
        JOIN dbo.FI_Factura F
            ON NC.IdFacturaNotaCredito = F.IdFactura
        JOIN dbo.PV_TipoMoneda TMF
            ON F.IdMoneda = TMF.IdMoneda
        LEFT JOIN dbo.S_Usuario UC
            ON NC.CreadoPor = UC.IdUsuario
        LEFT JOIN dbo.TA_FlujoTarea FT
            ON O.IdFlujoTarea = FT.IdFlujoTarea
        LEFT JOIN dbo.TA_TipoFlujoTarea TFT
            ON FT.IdTipoFlujo = TFT.IdTipoFlujoTarea
        LEFT JOIN dbo.AD_RegistroEliminacion RE
            ON NC.IdEliminado = RE.IdEliminacion
        LEFT JOIN dbo.S_Proveedor PV
            ON P.IdSubcontratista = PV.IdProveedor
    WHERE NC.IdAceptacionPedido = @IdAceptacionPedido
          AND P.IdSubcontratista = @IdProveedor
          AND NC.IdAceptacionNotaCredito = @IdNoNotaCredito;

    SELECT *
    FROM #tempselect;

END;