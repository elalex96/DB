-- p_OT_MaterialesProgramaSinAsignar 4
CREATE PROC p_OT_MaterialesProgramaSinAsignar
@pIdOTSolicitud INT
AS 

	SELECT 
	otm1.IdOTSolicitudMaterial,
		MAT.IdSCMaterial,
		mm.IdMaestro,
		mat.Descripcion,
		mat.DescripcionCorta
	FROM OT_Solicitud ot
	INNER JOIN dbo.SC_SubContrato sc ON sc.IdSubContrato = ot.IdSubContrato
	INNER JOIN dbo.SC_Materiales MAT ON MAT.IdSubContrato = SC.IdSubContrato
	INNER JOIN Petrovendor.dbo.MM_Maestro mm ON mm.IdMaestro = mat.IdMaestro
	INNER JOIN dbo.OT_SolicitudMaterial otm1 ON otm1.IdOTSolicitud = ot.IdOTSolicitud	 AND
												otm1.IdSCMaterial = MAT.IdSCMaterial
	WHERE ot.IdOTSolicitud = @pIdOTSolicitud AND 
	NOT EXISTS(
		SELECT 1
		FROM dbo.OT_SolicitudPrograma sp
		WHERE sp.IdOTSolicitudMaterial = otm1.IdOTSolicitudMaterial
	)
	GROUP BY ot.IdOTSolicitud,
		MAT.IdSCMaterial,
		mat.Descripcion,
		mat.DescripcionCorta,
		otm1.IdOTSolicitudMaterial,
		mm.IdMaestro
