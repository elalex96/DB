IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_CO_TipoProgramaActividad'
    )
    DROP PROCEDURE USP_SEL_CO_TipoProgramaActividad
GO
CREATE PROCEDURE [dbo].[USP_SEL_CO_TipoProgramaActividad]
    @UsuarioId INT,
	@ContratoId INT
	AS
    BEGIN
        SET NOCOUNT ON

		SELECT * FROM CO_TipoProgramaActividad (NOLOCK) WHERE ACTIVO = 1 ORDER BY IdTipoProgramaActividad DESC;

	END;

