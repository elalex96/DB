create proc EN_sp_FrecuenciaEntregablesExport
as
begin
	select 
	FE.IdFrecuenciaEntregable,
	ISNULL(FE.FrecuenciaEntregable,'') AS FrecuenciaEntregable,
	ISNULL(FE.FrecuenciaIngles,'') AS FrecuenciaIngles,
	Cantidad = ISNULL((Select count(IdFrecuenciaEntregable) from EN_Entregable where IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable AND IsEliminado = 0 AND IsActivo = 1),0)
	from [dbo].[EN_FrecuenciaEntregable] as FE
				
	SELECT 
	E.IdFrecuenciaEntregable,
	ISNULL(E.Consecutivo,'') AS Consecutivo,
	ISNULL(E.DocumentoEntregable,'') AS DocumentoEntregable,
	ISNULL(ML.MarcoLegal,'') AS MarcoLegal
	FROM EN_Entregable E
	LEFT JOIN EN_MarcoLegal ML
	ON E.IdMarcoLegal = ML.IdMarcoLegal
	WHERE 
	E.IsEliminado = 0
	AND E.IsActivo = 1
end
