
-- sp_SC_ConsultaMaterial 6
Create Proc [dbo].[sp_SC_ConsultaMaterial]
@pIdSubContrato int
As

	select 
	
		--sc.IdSubContrato,
		--sc.IdSubContratista,
		--pv.RazonSocial,
		--sc.IdContratista,
		--c.NombreContratista,
		--sc.NumeroSubContrato,
		--sc.CreadoPor,
		--sc.CreadoEl,
		--sc.ModificadoPor,
		--sc.ModificadoEl
		mat.IdSCMaterial,
		sc.IdSubContrato,
		mat.Concepto,
		mat.IdMaestro,
		maestro.IdSubFamilia,
		mat.IdUnidad,
		mat.IdServicio,
		NombreUnidad = u.NombreUnidad,
		mat.Cantidad,
		mat.PrecioUnitario,
		mat.Importe,
		mat.Descripcion,
		mat.DescripcionCorta,
		mat.CreadoPor,
		mat.CreadoEl,
		mat.ModificadoPor,
		mat.ModificadoEl
	from SC_SubContrato sc
	inner join CO_Contratista c on c.IdContratista = sc.IdContratista
	inner join PV_Subcontratista pv on pv.IdSubContratista = sc.IdSubContratista
	inner join SC_Materiales mat on mat.IdSubContrato = sc.IdSubContrato	
	inner join mm_unidad u on u.IdUnidad = mat.IdUnidad
	inner join Petrovendor.dbo.mm_maestro maestro on maestro.IdMaestro = mat.IdSCMaestro
	where sc.IdSubContrato = @pIdSubContrato


