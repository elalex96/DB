-- =============================================
-- Author:		<Jose Roman>
-- Create date: <15/02/2018>
-- Description:	<Se guarda o actualiza el perfil social>
-- =============================================
-- 24/11/2021 MC quitar prints ISSUE 383 adincopetrodb
-- =============================================
CREATE PROCEDURE [dbo].[PV_SP_GuardarPerfilSocial]
	@IdProveedor INT,
	@SitioWeb VARCHAR(max),
	@Facebook VARCHAR(MAX),
	@Twitter VARCHAR(MAX),
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/

AS
BEGIN

	DECLARE @Existe INT

	SET @Existe = (SELECT COUNT(IdPerfilSocial) FROM dbo.PV_PerfilSocial WHERE IdProveedor = @IdProveedor)
	IF(@Existe = 0)
	begin
		INSERT INTO dbo.PV_PerfilSocial
		(
			IdProveedor,
			SitioWeb,
			Facebook,
			Twitter
		)
		VALUES
		(   @IdProveedor,  -- IdProveedor - int
			@SitioWeb, -- SitioWeb - varchar(max)
			@Facebook, -- Facebook - varchar(max)
			@Twitter  -- Twitter - varchar(max)
		)
	END
    ELSE
    BEGIN
		UPDATE dbo.PV_PerfilSocial
			SET SitioWeb = @SitioWeb,
				Facebook = @Facebook,
				Twitter = @Twitter
			WHERE IdProveedor = @IdProveedor
    end
end
