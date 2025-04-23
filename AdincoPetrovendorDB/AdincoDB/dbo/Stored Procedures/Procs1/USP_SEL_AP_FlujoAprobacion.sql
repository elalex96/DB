
IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_AP_FlujoAprobacion'
    )
    DROP PROCEDURE USP_SEL_AP_FlujoAprobacion;
GO
CREATE PROCEDURE USP_SEL_AP_FlujoAprobacion
    @IdUsuario INT,
    @IdContrato INT
AS
BEGIN
	SELECT FlujoAprobacionId,
			CO_Contratista.RazonSocial AS RazonSocial,
			AP_FlujoAprobacion.Descripcion,
			AP_FlujoAprobacionTipos.Descripcion AS DescripcionTipo,
			Activo,
			AP_FlujoAprobacion.CreadoEl,
			AP_Usuario.Nombre	AS	CreadoPor
			FROM 
				AP_FlujoAprobacion (NOLOCK)
			JOIN
				AP_FlujoAprobacionTipos (NOLOCK)
				ON AP_FlujoAprobacion.TipoFlujoAprobacionId	=	AP_FlujoAprobacionTipos.TipoFlujoAprobacionId
			JOIN
				CO_Contratista (NOLOCK)
				ON	
				AP_FlujoAprobacion.IdContratista	=	CO_Contratista.IdContratista
			JOIN
				AP_Usuario (NOLOCK)
				ON AP_FlujoAprobacion.CreadoPor = AP_Usuario.UsuarioID;
END
