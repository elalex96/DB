

-- p_SC_InstalacionLineaPresupuesto '14818'
Create Proc p_SC_InstalacionLineaPresupuesto
@pIdLineaPresupuestos varchar(500)
as


	select *
	into #tmpLinea
	from [dbo].[fnSplitString](@pIdLineaPresupuestos,',')

	select i.* from co_instalacion i
	inner join CO_LineaPresupuestoMes lpm on lpm.IdInstalacion =  i.IdInstalacion
	inner join #tmpLinea tmp on tmp.splitdata = lpm.IdLineaPresupuestoMes
	where i.activo = 1 
	order by NombreInstalacion


