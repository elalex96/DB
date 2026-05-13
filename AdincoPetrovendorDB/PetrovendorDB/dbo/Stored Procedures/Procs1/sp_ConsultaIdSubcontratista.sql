CREATE PROCEDURE [dbo].[sp_ConsultaIdSubcontratista]
(
    @RFC NVARCHAR(MAX)
)
AS
BEGIN
	SELECT IdProveedor FROM S_Proveedor WHERE RFC = @RFC
END	



