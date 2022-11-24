-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_WS_ConsultarContactosXRFC]
@RFC VARCHAR(30)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
					SELECT C.* FROM S_Contacto C 
					INNER JOIN S_Proveedor P
					ON C.IdProveedor = P.IdProveedor
					WHERE P.RFC = @RFC
					
    

END

