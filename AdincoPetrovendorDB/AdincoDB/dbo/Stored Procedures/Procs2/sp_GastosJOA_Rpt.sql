
create proc sp_GastosJOA_Rpt
(
	@IdContrato		int,
	@FechaIni		datetime,
	@FechaFin		datetime
)
as
begin

	SELECT DISTINCT
			
		   campo.Descripcion,
		   ccsh.Nivel3					AS 'Cuenta Contable', 
		   RIGHT(convert(varchar(6),t.FechaPago,113),3)			AS 'Fecha Pago', 
		   YEAR(t.FechaPago)			AS 'Año Pago', 
		   f.UUID						AS 'FOLIO FISCAL (UUID)', 
		   f.Fecha						AS 'Fecha Factura / Fecha CFDI', 
		   case							when	t.FechaPago is null then 'NO'  else 'Si' end,
		   t.FechaPago,
		   isnull(cast(porc.PorcentajePemex as varchar),'') as PorcParticipacion,
		   ap.id_Actividad, 
		   ap.DescripcionActividadPetrolera as Actividad,
		   --
		   sa.[id_Sub-actividad], 
			sa.SubactividadPetrolera as SubActividad,
			ta.id_Tarea,
			ta.TareaPetrolera as Tarea,
			campo.Descripcion as Campo,
			yac.NombreYacimiento as Yacimiento,
		   poz.Nombre			AS Pozo, 
		   p.RazonSocial				AS Proveedor, 
		   f.Emisor						AS 'Proveedor RFC',
		   s.NombreServicio				AS SubTarea, 
		   l.CPXOPX,
		   '',
		   '',
		   tm.TipoMonedaCorto			AS 'Moneda Pago',
		   'Tipo De Cambio'				= tc2.TipoCambio	/*CASE	WHEN f.IdMoneda = 1	THEN tc2.TipoCambio
													WHEN f.IdMoneda = 2 THEN tc.TipoCambio
													ELSE 0
													END*/,
		   t.MontoPagado				AS 'Importe Pagado En MO',
		   (f.MontoConIva * 16) / 116	AS IVA,
		  
		  case when  t.IdMoneda = 1  then t.MontoPagado * (isnull(porc.PorcentajePemex ,0) /100) 
				when  t.IdMoneda = 2 then (t.MontoPagado * (isnull(porc.PorcentajePemex,0) /100) ) /tc2.TipoCambio
			end
			as importe_pesos_participacion,

			case when  t.IdMoneda = 1  then  ((f.MontoConIva * 16) / 116) * (isnull(porc.PorcentajePemex ,0) /100)
				when t.IdMoneda = 2  then ((f.MontoConIva * 16) / 116) * (isnull(porc.PorcentajePemex ,0) /100) /tc2.TipoCambio
			end
		   	as IVA_PARTICIPACION
		   /*
		   MONTH(t.FechaPago)			AS 'Mes Pago', 
		   ccsh.Descripcion				AS 'Cuenta Contable Nombre', 
		   f.Moneda						AS 'Moneda Factura', 
		   NULL							AS 'Costo Pemex', 
		   f.MontoConIva				AS 'Importe De Factura', 
		   NULL							AS RetISR, 
		   NULL							AS RetIVA, 
		   CASE
			   WHEN f.IdMoneda = 1
			   THEN(t.MontoPagado / tc.TipoCambio)
			   WHEN f.IdMoneda = 2
			   THEN(t.MontoPagado / tc.TipoCambio)
			   ELSE 0
		   END							AS 'Importe Pagado USD', 
		   NULL							AS IVA2, 
		   NULL							AS Ret, 
		   NULL							AS ISR3, 
		   NULL							AS RETIVA4, 
		   NULL							AS TOTAL, 
		   NULL							AS REF, 
		   f.IdFactura, 
		   
		   Conceptos = STUFF(
				(
					SELECT CAST(', ' AS VARCHAR(MAX))+CONVERT(NVARCHAR(MAX), Descripcion)
					FROM dbo.FI_CFDIConcepto fc
						 JOIN dbo.FI_Factura fp ON fp.IdFactura = fc.IdFactura
					WHERE fc.IdFactura = f.IdFactura
					GROUP BY fp.IdFactura, 
							 Descripcion FOR XML PATH('')
				), 1, 1, '')*/
	FROM dbo.FI_Factura f
		 JOIN dbo.CO_Registro r					ON r.IdFactura = f.IdFactura
		 JOIN dbo.CO_LineaPresupuestoMes l		ON l.IdLineaPresupuestoMes = r.IdPrograma
		 JOIN dbo.CO_ActividadPetroleraCNH ap	ON ap.IdActividadPetrolera = l.IdActividadPetrolera
		 JOIN dbo.CO_SubactividadPetrolera sa	ON sa.IdSubactividadPetrolera = l.IdSubactividadPetrolera
		 JOIN dbo.CO_TareaPetrolera ta			ON ta.IdTareaPetrolera = l.IdTareaPetrolera
		 JOIN dbo.CO_Servicio s					ON s.IdServicio = l.IdServicio
		 JOIN dbo.CO_Instalacion i				ON i.IdInstalacion = r.IdInstalacion
		 LEFT JOIN PR_CAMPO campo on campo.Id = i.IdCampo
		 LEFT JOIN CO_Yacimiento yac on yac.IdYacimiento = i.IdYacimiento
		 LEFT JOIN PR_Pozo poz on poz.Id = i.WelIID
		 JOIN dbo.FI_TransferFactura tf			ON tf.IdFactura = f.IdFactura
		 JOIN dbo.FI_Transfer t					ON t.IdTransferencia = tf.IdTransfer
		 JOIN dbo.CO_CatalogoCuentaSH ccsh		ON ccsh.IdCatalogoCuentasSH = r.IdCatalogoCuentasSH
		 JOIN dbo.PV_Subcontratista p			ON p.IdSubcontratista = f.IdSubcontratista
		 left join CO_PorcentajesContrato porc on porc.idContrato = f.IdContrato
		 LEFT JOIN dbo.CO_TipoCambioDiario tc	ON f.IdMoneda = tc.IdMoneda 												
												 AND YEAR(f.Fecha) = YEAR(tc.Fecha)
												 AND MONTH(f.Fecha) = MONTH(tc.Fecha)
												 AND DAY(f.Fecha) = DAY(tc.Fecha)
		 LEFT JOIN dbo.PV_TipoMoneda tm			ON tm.IdMoneda = t.IdMoneda

		  LEFT JOIN dbo.CO_TipoCambioDiario tc2	ON tc2.IdMoneda = 1												
												 AND YEAR(f.Fecha) = YEAR(tc2.Fecha)
												 AND MONTH(f.Fecha) = MONTH(tc2.Fecha)
												 AND DAY(f.Fecha) = DAY(tc2.Fecha)

		

	WHERE		f.IdContrato = @IdContrato --10036
	AND			(t.FechaPago <= @FechaIni )-->= '2019-04-01'
	ORDER BY t.FechaPago DESC;
end

