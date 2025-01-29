IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_AP_CalculaFechaConDiasHabiles'
    )
    DROP PROCEDURE USP_SEL_AP_CalculaFechaConDiasHabiles
GO
CREATE PROCEDURE [dbo].[USP_SEL_AP_CalculaFechaConDiasHabiles]
@IdContrato    INT = 0,
@IdUsuario    INT = 0,
@FechaInicial   DATE,
@DiasParaCalculo INT
AS
    BEGIN
SET NOCOUNT ON
	CREATE TABLE #DiasHabiles
	(
		Id	INT IDENTITY (1,1),
		IdFecha	DATE
	)
	INSERT INTO #DiasHabiles
	(
		IdFecha
	)
	SELECT
		A.IdFecha
	FROM 
		dbo.AP_Calendario A
	WHERE
		A.IdFecha	>=	@FechaInicial
		AND	DATEADD(MONTH, 1,@FechaInicial)	>=	A.IdFecha
		AND FinDeSemana		=	0
		AND DiaLaborable	=	1
	ORDER BY
		A.IdFecha

	SELECT IdFecha
	FROM #DiasHabiles 
	WHERE Id = @DiasParaCalculo


END