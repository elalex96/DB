use Petrovendor

go

if exists (select * from sys.procedures where name = 'SP_VerificarPermisos')
begin
	drop proc SP_VerificarPermisos
end

go
-- =============================================
-- Author:		<Pedro ,,Acuña >
-- Modified date: <02/Enero/2018>
-- Description:	<Se modifica el filtro ya que anteriormente filtraba por rol pero para todas las aplicaciones y no hacia distincion >
-- =============================================
CREATE PROCEDURE [dbo].[SP_VerificarPermisos]
    @IdTipoUsuario INT,
    @IdModulo INT,
    @IdProveedor INT,
    @IdUsuario INT,
    @IdContrato INT,
    @fchRegistro DATETIME
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


    IF ((	SELECT COUNT(PM.IdPerfilModulo)
            FROM dbo.PerfilModulo PM
            WHERE PM.IdPerfil = @IdTipoUsuario
                AND PM.IdModulo = @IdModulo
                AND PM.IdFiltroProveedor = @IdProveedor
                AND PM.Activo = 1) 
				> 0)
    BEGIN
        SELECT 'PERMISO_DENEGADO'
    END
    ELSE
    BEGIN
        SELECT 'MODULO_ACCESIBLE'
    END



END

go
--exec SP_VerificarPermisos @IdTipoUsuario=3,@IdModulo=255,@IdProveedor=516,@IdUsuario=0,@IdContrato=0,@fchRegistro='2021-02-06 15:00:49'