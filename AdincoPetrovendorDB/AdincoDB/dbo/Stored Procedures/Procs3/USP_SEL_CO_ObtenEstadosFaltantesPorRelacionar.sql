IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_CO_ObtenEstadosFaltantesPorRelacionar'
    )
    DROP PROCEDURE USP_SEL_CO_ObtenEstadosFaltantesPorRelacionar;
GO
CREATE PROCEDURE [dbo].[USP_SEL_CO_ObtenEstadosFaltantesPorRelacionar]--1,1,10,10007
	@IdUsuario            INT = 0,
    @IdContrato            INT,
	@IdUsuarioSeleccion            INT,
	@IdContratoSeleccion	INT
AS
    BEGIN
	CREATE TABLE #EstadosClv(
	IdClvEstado	 INT,
	NombreEstado VARCHAR(150),
	Descripcion VARCHAR(8000)
	);

	INSERT INTO #EstadosClv(
	IdClvEstado	,
	NombreEstado,
	Descripcion)
	SELECT 
	IdClvEstado,
	NombreEstado,
	Descripcion
	FROM 
		CO_EstadoRegistro_V2 (NOLOCK)
	WHERE IdContrato	=	@IdContratoSeleccion
	AND Activo	=	1;

					SELECT 
					EstadosClv.IdClvEstado,
					EstadosClv.NombreEstado,
					EstadosClv.Descripcion
					FROM 
						#EstadosClv	AS EstadosClv
					LEFT JOIN
						CO_EstadoRegistroUsuario	 (NOLOCK)
						ON	EstadosClv.IdClvEstado	=	CO_EstadoRegistroUsuario.IdClvEstado
						AND CO_EstadoRegistroUsuario.IdUsuario = @IdUsuarioSeleccion
						
					WHERE 
						CO_EstadoRegistroUsuario.IdEstadoRegistroUsuario IS NULL
					ORDER BY  EstadosClv.NombreEstado ASC
END