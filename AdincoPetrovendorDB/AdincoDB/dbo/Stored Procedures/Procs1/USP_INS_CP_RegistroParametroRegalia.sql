IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_INS_CP_RegistroParametroRegalia'
    )
    DROP PROCEDURE USP_INS_CP_RegistroParametroRegalia;
GO
CREATE PROCEDURE USP_INS_CP_RegistroParametroRegalia
    @IdUsuario INT,
    @IdContrato INT,
	@IdParametroRegalias INT = 0,
	@Anio INT,
	@An FLOAT,
	@Bn FLOAT,
	@Cn FLOAT,
	@En FLOAT,
	@Dn FLOAT,
	@Fn FLOAT,
	@Gn FLOAT, 
	@Hn FLOAT
AS
BEGIN

IF(@IdParametroRegalias=0)
BEGIN
	INSERT INTO CP_ParametroRegalia (Anio,An,Bn,Cn,Dn,En,Fn,Gn,Hn) VALUES (@Anio,@An ,@Bn ,@Cn ,@En ,@Dn ,@Fn,@Gn ,@Hn );
END
ELSE
UPDATE CP_ParametroRegalia
SET Anio = @Anio,An=@An,Bn=@Bn,Cn = @Cn,Dn=@Dn,En=@En,Fn=@Fn,Gn=@Gn,Hn=@Hn
WHERE 
IdParametroRegalias = @IdParametroRegalias;

END
