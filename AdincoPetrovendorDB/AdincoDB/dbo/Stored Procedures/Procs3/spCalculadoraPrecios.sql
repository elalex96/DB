-- spCalculadoraPrecios 10019,'20181101'
CREATE proc [dbo].[spCalculadoraPrecios]
	@Contrato INT,
	@Mes      DATE
as
begin

	SELECT top 50--Limitar a 50 filas ya que el excel que recibirá los datos solo soporta ese número de filas
		Folio = FI_F.UUID,
		FechaTransaccion = convert(varchar,COM_OC.FechaTransaccion,103),		
		Temperatura = 15.56,
		Unidad	=	'MMF',
		--Unidad =  case when fc.Unidad = 'MF' then 'miles de pies cúbicos'
		--				when fc.Unidad = 'MMF' then 'millones de pies cúbicos'
		--				ELSE 'ND'
		--			end,
		--Cantidad=fc.Cantidad,
		Cantidad = PMS.VolumenProgramado,
		Unidad2=FI_F.Moneda,
		Importe = case when FI_F.IdMoneda = 1 then   FI_F.SubTotal / isnull(tc.TipoCambio,1) 
						else  FI_F.SubTotal
					End,
		TipoCambio = isnull(tc.TipoCambio,1),
		H2S=isnull(crov.MOL_h2S,0),
		CO2= isnull(crov.MOL_CO2,0),
		N2=isnull(MOL_N2,0),
		C1 =isnull(C1,0),
		C2 = isnull(C2,0),
		C3 = isnull(C3,0),
		lC4 = isnull(lC4,0),
		NC4 = isnull(NC4,0),
		lC5 = isnull(lC5,0),
		NC5= isnull(NC5,0),
		C6 = isnull(C6_plus,0),
		C7 = isnull(C7,0),
		C8 = isnull(C8,0),
		C9 = isnull(C9,0),
		C10 = isnull(C10,0),
		Total = isnull(MOL_h2S,0) + isnull(MOL_CO2,0) + isnull(MOL_N2,0)+isnull(C1,0)+isnull(C2,0)+
				isnull(C3,0)+isnull(lC4,0)+isnull(NC4,0)+isnull(lC5,0)+isnull(NC5,0)+isnull(C6_plus,0)+isnull(C7,0)+
				isnull(C8,0)+isnull(C9,0)+isnull(C10,0)
	into #tmpResult
    FROM CO_Contrato C(NOLOCK)
		JOIN CO_Contratista CC(NOLOCK) ON C.IdContratista = CC.IdContratista
        JOIN COM_OperacionComercializacion COM_OC(NOLOCK) ON C.IdContrato = COM_OC.IdContrato
                                                            AND COM_OC.MesReporte = @Mes
		JOIN PR_ProduccionMensualSipac	PMS
			ON	C.IdContrato	=	PMS.IdContrato
			AND	COM_OC.MesReporte 	=	PMS.IdFecha
			AND COM_OC.PuntoEntregaID = PMS.PuntoEntregaID
			AND PMS.IdHidrocarburo	=	1000
        JOIN FI_Factura FI_F(NOLOCK) ON COM_OC.IdFactura = FI_F.IdFactura
        JOIN CO_TipoHidrocarburo CO_TH ON COM_OC.IdTipoHidrocarburo = CO_TH.IdTipoHidrocarburo
		inner join	FI_CFDIConcepto		fc on			fc.IdFactura					=	FI_F.IdFactura
		inner join CO_Cromatografia cro on cro.IdContrato = FI_F.IdContrato and
										cro.Anio = year(COM_OC.MesReporte) and
										cro.Mes = MOnth(COM_OC.MesReporte)
		JOIN CO_PuntosdeEntregaContrato	PEC
			ON	C.IdContrato	=	PEC.idContrato
			AND COM_OC.PuntoEntregaID	=	PEC.PuntoEntregaID
		inner join [dbo].[CO_CromatografiaValores] crov on crov.IdCromatografia = cro.IdCromatografia and
								 PEC.PuntoEntregaContratoID = crov.IdPuntoEntregaContrato
		left join CO_TipoCambioDiario tc on tc.Fecha = CONVERT(DATE,FI_F.Fecha,111) and
									tc.IdMoneda = FI_F.IdMoneda
    WHERE C.IdContrato = @Contrato
        AND convert(varchar,COM_OC.MesReporte,112) = convert(varchar,@Mes,112) and
		 CO_TH.TipoHidrocarburo in (3,4,5,6)
	group by  FI_F.UUID,
		COM_OC.FechaTransaccion,
		FI_F.Fecha,		
		--fc.Unidad,
		--fc.Cantidad,
		PMS.VolumenProgramado,
		FI_F.Moneda,
		 FI_F.SubTotal,
		 crov.MOL_h2S,
		crov.MOL_CO2,
		MOL_N2,
		C1 ,
		C2,
		C3,
		lC4,
		NC4,
		lC5,
		NC5,
		C6_plus,
		C7,
		C8,
		C9,
		C10, tc.TipoCambio,FI_F.IdMoneda

	having isnull(MOL_h2S,0) + isnull(MOL_CO2,0) + isnull(MOL_N2,0)+isnull(C1,0)+isnull(C2,0)+
				isnull(C3,0)+isnull(lC4,0)+isnull(NC4,0)+isnull(lC5,0)+isnull(NC5,0)+isnull(C6_plus,0)+isnull(C7,0)+
				isnull(C8,0)+isnull(C9,0)+isnull(C10,0) > 0
	order by 
		FI_F.UUID

	select * ,
	nFacturas = (select count(distinct Folio) from #tmpResult)
	from #tmpResult

end
