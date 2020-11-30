CREATE procedure p_SC_DetalleImportacionContrato
@pIdSCCarga int ,
@pIdUsuario int = null,
@pIdContrato int = null 
as
begin 
	select 
	sci.RFCProveedor
	,sci.FechaPedido
	,sci.NumeroPedido
	,sci.FechaContratoIni
	,sci.FechaContratoFin
	,sci.Descripcion
	,sci.DiasCredito
	,sci.Partida
	,sci.DescripcionPartida
	,sci.UnidadMedida
	,sci.Cantidad
	,sci.PrecioUnitario
	, sci.Moneda
	, sci.Importe
	, tp.TipoPedido as RazonSocial
	, case 
		when sci.IdSubcontrato > 0 
						then 1 
						else 0 
						end as IdSubcontrato
	from SC_importacion as sci
	left join PETROVENDOR.[dbo].[MM_TipoPedido] as tp on sci.IdTipoPedido = tp.IdTipoPedido

	where IdSCCarga = @pIdSCCarga
end
