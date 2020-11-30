CREATE VIEW [dbo].[ReporteDeAceptaciones]
AS

/*
select '' as NumeroContrato,
'' as NombreAreaContractual,
'' as Operadora,
0 as IdAceptacionPedido,
0 as IdPedido,
'' as Comentario,
getdate() as FechaRegistro,
'' as DomiclioEntrega,
'' as Proveedor,
'' as Nombre,
0 as IdPedidoGeneral,
'' as TipoPedido,
0 as TotalPedido,
'' as Moneda,
'' as RFC,
'' as TipoDomicilio,
'' as Estatus
*/
     SELECT C.NumeroContrato,
            AC.NombreAreaContractual,
            PC.RazonSocial AS Operadora,
            AF.IdAceptacionPedido,
            Pe.IdPedido,
            AP.Comentario,
            O.FechaRegistro,
            CONCAT(DG.Calle, ', ', DG.NoExterior, ',', ISNULL('Int.'+DG.NoExterior, ''), ', Col.', DG.Colonia, ', ', DG.CodigoPostal, ', ', DG.Municipio, ', ', DG.Estado, ', ', DG.Pais) AS DomiclioEntrega,
            PR.RazonSocial+' '+ISNULL(Pr.RegimenCapital, '') AS Proveedor,
            E.Nombre,
            PG.IdPedido AS IdPedidoGeneral,
            TP.TipoPedido,
            SUM((APD.Cantidad + APD.Excedente) * PED.PrecioUnitario) AS TotalPedido,
            TM.TipoMonedaCorto AS Moneda,
            PR.RFC,
            TDG.TipoDomicilio,
            E.Nombre AS Estatus
     FROM MM_AceptacionFactura AS AF (NOLOCK)
          JOIN TA_Operacion AS O (NOLOCK)
			ON AF.IdAceptacionFactura = O.IdDocumento
			AND O.IdTipoOperacion = 10
          JOIN TA_Estatus AS E (NOLOCK)
			ON O.IdEstatusOperacion = E.IdEstatus
          JOIN MM_AceptacionPedido AS AP (NOLOCK)
			ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
          JOIN dbo.MM_AceptacionPedidoDetalle AS APD (NOLOCK)
			ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
          JOIN MM_Pedido AS PE (NOLOCK)
			ON AP.IdPedido = PE.IdPedido
			AND PE.IdProveedorCompras IN (606, 690)
		  JOIN dbo.S_UsuarioProveedor UP (NOLOCK)
			ON PE.IdProveedorCompras = UP.IdProveedor
          JOIN Adinco.dbo.CO_Contrato C (NOLOCK)
			ON PE.IdContrato = C.IdContrato
          JOIN Adinco.dbo.CO_AreaContractual AC (NOLOCK)
			ON C.IdAreaContractual = AC.IdAreaContractual
          JOIN MM_PedidoDetalle AS PED (NOLOCK)
			ON PE.IdPedido = PED.IdPedido
                         AND APD.IdPedidoDetalle = PED.IdPedidoDetalle
          JOIN MM_Pedidos AS PG (NOLOCK)
			ON PE.IdPedido = PG.IdIdentificador
                           AND PG.IdProveedorCliente IN (606, 690)
          JOIN S_Proveedor AS PR (NOLOCK)
			ON PE.IdSubcontratista = PR.IdProveedor
          JOIN dbo.S_Proveedor PC (NOLOCK)
			ON PE.IdProveedorCompras = PC.IdProveedor
          JOIN dbo.PV_TipoMoneda AS TM (NOLOCK)
			ON TM.IdMoneda = PE.IdMoneda
          LEFT JOIN dbo.MM_TipoPedido AS TP (NOLOCK)
			ON PG.IdTipoPedido = TP.IdTipoPedido
          LEFT JOIN dbo.DG_Domicilio AS DG (NOLOCK)
			ON AP.IdDomicilioEntrega = DG.IdDomicilio
          LEFT JOIN dbo.DG_TipoDomicilio AS TDG (NOLOCK)
			ON DG.IdTipoDomicilio = TDG.IdTipoDomicilio

     WHERE O.IdTipoOperacion = 10
           AND PE.IdProveedorCompras IN (606, 690)
     GROUP BY C.NumeroContrato,
              AC.NombreAreaContractual,
              PC.RazonSocial,
              AF.IdAceptacionPedido,
              Pe.IdPedido,
              O.FechaRegistro,
              PR.RazonSocial,
              Pr.RegimenCapital,
              E.Nombre,
              PG.IdPedido,
              TP.TipoPedido,
              TM.TipoMonedaCorto,
              PR.RFC,
              DG.Calle,
              DG.NoExterior,
              DG.NoInterior,
              DG.Colonia,
              DG.Estado,
              DG.Municipio,
              DG.Pais,
              DG.CodigoPostal,
              TDG.TipoDomicilio,
              AP.Comentario;
