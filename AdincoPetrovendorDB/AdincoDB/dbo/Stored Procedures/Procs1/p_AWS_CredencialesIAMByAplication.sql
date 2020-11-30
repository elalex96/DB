create PROCEDURE [dbo].[p_AWS_CredencialesIAMByAplication]
@IdAplicacion int
as
begin
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
