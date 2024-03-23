USE PETROVENDOR
DROP PROC IF EXISTS p_AWS_CredencialesIAMByApp
GO
-- Author:		David
-- Create date: marzo 31 24
-- Description:	Se optimiza sp Issue #2686 petrovendor
-- =============================================
CREATE PROCEDURE p_AWS_CredencialesIAMByApp
(
	@IdAplicacion int
)
as
BEGIN

SELECT 
	aws.Id
	,aws.AccessKey
	,aws.SecretKey
	,aws.ServiceUrl
	,aws.DefaultBucket
	FROM ADINCO..Amazon_Credenciales aws 
		WHERE IdAplicacion = @IdAplicacion
		and aws.Esactivo =1

end
