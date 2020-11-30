CREATE PROC p_OT_ConsultarMaterialBitacora
@pIdOTSolicitudMaterial INT
AS
	SELECT bita.Cantidad,
		bita.FechaProgramacionInicio,
		bita.FechaProgramacionFin,
		bita.CreadoEl,
		TipoUsuario= CASE WHEN bita.IdTipoUsuario = 1 THEN 'Contratista' ELSE 'Subcontratista' end
	FROM dbo.OT_SolicitudMaterialBitacora  bita
	WHERE bita.IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
	ORDER BY bita.CreadoEl DESC
