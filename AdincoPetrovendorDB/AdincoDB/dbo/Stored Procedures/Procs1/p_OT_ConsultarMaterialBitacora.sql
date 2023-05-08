
CREATE PROC [dbo].[p_OT_ConsultarMaterialBitacora]
@pIdOTSolicitudMaterial INT
AS
	SELECT OT_SolicitudMaterialBitacora.Cantidad,
		OT_SolicitudMaterialBitacora.FechaProgramacionInicio,
		OT_SolicitudMaterialBitacora.FechaProgramacionFin,
		OT_SolicitudMaterialBitacora.CreadoEl,
		TipoUsuario= CASE WHEN OT_SolicitudMaterialBitacora.IdTipoUsuario = 1 THEN 'Contratista' ELSE 'Subcontratista' end
	FROM dbo.OT_SolicitudMaterialBitacora (NOLOCK)
	WHERE OT_SolicitudMaterialBitacora.IdOTSolicitudMaterial = @pIdOTSolicitudMaterial
	ORDER BY OT_SolicitudMaterialBitacora.CreadoEl DESC
