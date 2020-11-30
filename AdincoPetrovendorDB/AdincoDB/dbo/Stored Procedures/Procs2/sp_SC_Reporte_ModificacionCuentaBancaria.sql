
Create Proc sp_SC_Reporte_ModificacionCuentaBancaria
@pIdSubContratista int,
@pDatoBancarioIDAnterior int,
@pDatoBancarioIDNuevo int
As


	select sc.IdSubContratista ,
		RazonSocial = sc.RazonSocial,
		NumeroCuentaAnterior = cuentaAnt.CuentaClave,
		NumeroCuentaNueva =  cuentaNue.CuentaClave,
		TipoMoneda = moneda.TipoMonedaCorto,
		banco.Banco,
		sc.RepresentanteLegal,
		FechaActual = convert(varchar,getdate(),103)
	from pv_subcontratista sc
	inner join PV_CuentaBancaria cuentaAnt  on cuentaAnt.DatoBancarioID = @pDatoBancarioIDAnterior
	inner join PV_CuentaBancaria cuentaNue  on cuentaNue.DatoBancarioID = @pDatoBancarioIDNuevo
	inner join PV_TipoMoneda moneda on moneda.IdMoneda =  cuentaNue.TipoMonedaID
	inner join PV_Banco banco on banco.BancoID = cuentaNue.BancoID
	where sc.IdSubcontratista = @pIdSubContratista

