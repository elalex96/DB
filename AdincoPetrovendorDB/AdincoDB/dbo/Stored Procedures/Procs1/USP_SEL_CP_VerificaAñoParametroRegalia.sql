IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_CP_VerificaAñoParametroRegalia'
    )
    DROP PROCEDURE USP_SEL_CP_VerificaAñoParametroRegalia;
GO
CREATE PROCEDURE USP_SEL_CP_VerificaAñoParametroRegalia
    @IdUsuario INT,
    @IdContrato INT,
	@IdParametroRegalias INT,
	@Anio INT
	AS  
BEGIN  
    SET NOCOUNT ON;
	
	SELECT COUNT(1)
	FROM
		CP_ParametroRegalia (NOLOCK)
	WHERE
		ANIO = @Anio AND IdParametroRegalias <> @IdParametroRegalias;

END