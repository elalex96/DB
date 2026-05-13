CREATE VIEW [dbo].[ConsultaComercializacionRenaissance]
AS
     SELECT TOP (100) PERCENT CC.NumeroContrato, 
                              ac.NombreAreaContractual, 
                              c.IdOperacionComercializacion, 
                              c.MesReporte, 
                              c.FechaTransaccion, 
                              c.IdTipoHidrocarburo, 
                              TH.Hidrocarburo, 
                              c.VolumenVendido, 
                              c.PrecioVentaUnitario, 
                              c.CostoUnitarioComercializacion, 
                              c.PrecioPuntoMedicion, 
                              c.NumeroFolioPedimento, 
                              c.EPT, 
                              c.OperacionBajoReglasMercado, 
                              c.ClasificacionDocumentoSoporte, 
                              UC.Nombre AS CreadoPor, 
                              c.CreadoEl, 
                              UM.Nombre AS ModificadoPor, 
                              C.ModificadoEl, 
                              c.Activo, 
                              c.NuevoPrecioVentaUnitario, 
                              c.PVUAnterior, 
                              c.PPMAnterior, 
                              c.PuntoEntregaID,
                              --c.EsCondensable ,
                              pe.Nombre AS [PuntoEntrega], 
                              c.IdFactura,
                              CASE
                                  WHEN ISNULL(fac.Serie, '') = ''
                                  THEN ISNULL(fac.Folio, '')
                                  ELSE ISNULL(fac.Serie, '')+''+ISNULL(fac.Folio, 0)
                              END AS [Factura], 
                              fac.Fecha, 
                              fac.SubTotal, 
                              FAC.MontoConIva, 
                              fac.Emisor, 
                              fac.Receptor, 
                              FAC.UUID
     FROM [COM_OperacionComercializacion] c WITH (NOLOCK)
          LEFT JOIN CO_PuntosdeEntrega pe WITH (NOLOCK)
		  ON pe.PuntoEntregaID = c.PuntoEntregaID
          LEFT JOIN FI_Factura fac WITH (NOLOCK)
		  ON fac.IdFactura = c.IdFactura
          JOIN dbo.CO_TipoHidrocarburo TH WITH (NOLOCK)
		  ON C.IdTipoHidrocarburo = TH.IdTipoHidrocarburo
          JOIN dbo.CO_Contrato CC WITH (NOLOCK)
		  ON CC.IdContrato = c.IdContrato
          LEFT JOIN dbo.AP_Usuario UC WITH (NOLOCK)
		  ON c.CreadoPor = UC.UsuarioID
          LEFT JOIN dbo.AP_Usuario UM WITH (NOLOCK)
		  ON C.ModificadoPor = UM.UsuarioID
          LEFT JOIN dbo.CO_AreaContractual ac WITH (NOLOCK)
		  ON ac.IdAreaContractual = CC.IdAreaContractual
     WHERE c.[IdContrato] IN(10001, 10002, 10003)
     ORDER BY CC.NumeroContrato, 
              c.FechaTransaccion DESC; 
