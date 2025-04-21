USE Adinco

GO
IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_CP_ParametroRegalia'
    )
    DROP PROCEDURE USP_SEL_CP_ParametroRegalia;
GO
CREATE PROCEDURE USP_SEL_CP_ParametroRegalia
    @IdUsuario INT,
    @IdContrato INT
AS
BEGIN
	SELECT IdParametroRegalias,Anio,An,Bn,Cn,Dn,En,Fn,Gn,Hn	FROM CP_ParametroRegalia (NOLOCK);
END
