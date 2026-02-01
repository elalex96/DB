IF EXISTS (
		SELECT 1
		FROM dbo.sysobjects
		WHERE name = 'USP_SEL_CO_RegistroMarkup_Bitacora'
		)
	DROP PROCEDURE USP_SEL_CO_RegistroMarkup_Bitacora;
GO
CREATE PROCEDURE dbo.USP_SEL_CO_RegistroMarkup_Bitacora
    @IdContrato INT																		   
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        B.BitacoraId,
        B.IdContrato,
        B.GastoId,
        B.FechaMovimiento,
        B.UsuarioId,
        U.Nombre AS Usuario,
        B.Justificacion,

        B.IdEstadoOrigen,
        EO.NombreEstado AS EstadoOrigen,

        B.IdEstadoDestino,
        ED.NombreEstado AS EstadoDestino,
		YEAR(R.MesPresentacion) AS Anio,
        FORMAT(R.MesPresentacion, 'MM MMMM', 'es-ES') AS Mes
    FROM dbo.CO_RegistroMarkup_Bitacora B WITH (NOLOCK)

	INNER JOIN dbo.CO_Registro R WITH(NOLOCK)
        ON B.GastoId = R.IdRegistro

    LEFT JOIN dbo.AP_Usuario U WITH (NOLOCK)
        ON B.UsuarioId = U.UsuarioID

    LEFT JOIN dbo.CO_EstadoRegistro_V2 EO WITH (NOLOCK)
        ON B.IdContrato = EO.IdContrato 
       AND B.IdEstadoOrigen = EO.IdClvEstado  

    LEFT JOIN dbo.CO_EstadoRegistro_V2 ED WITH (NOLOCK)
        ON B.IdContrato = ED.IdContrato 
       AND B.IdEstadoDestino = ED.IdClvEstado 

    WHERE B.IdContrato = @IdContrato
    ORDER BY B.FechaMovimiento DESC, B.BitacoraId DESC;
END
GO
