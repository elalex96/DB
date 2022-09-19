-- p_OT_TerminosCondiciones_Sel 10005
create proc [dbo].[p_OT_TerminosCondiciones_Cmb]
@pIdContratista int
as

	select distinct TC_TerminosYCondicionesDocV2.IdTerminosYCondiciones,
		TC_TerminosYCondicionesDocV2.Nombre,
		TC_TerminosYCondicionesDocV2.Comentario
	from CO_Contratista (NOLOCK)
	inner join Petrovendor..S_Proveedor (NOLOCK) on CO_Contratista.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = S_Proveedor.RFC collate SQL_Latin1_General_CP1_CI_AS 
	inner join PEtrovendor..TC_TerminosYCondicionesDocV2 (NOLOCK) on S_Proveedor.Idproveedor = TC_TerminosYCondicionesDocV2.IdProveedor  
	where CO_Contratista.IdContratista = @pIdContratista
	
GO


