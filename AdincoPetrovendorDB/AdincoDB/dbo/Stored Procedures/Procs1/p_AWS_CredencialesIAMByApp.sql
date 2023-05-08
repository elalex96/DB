
CREATE PROCEDURE p_AWS_CredencialesIAMByApp
(
	@IdAplicacion int
)
as
begin
	SELECT	aws.Id,
			aws.AccessKey,
			aws.SecretKey,
			aws.ServiceUrl,
			aws.DefaultBucket
	FROM	ADINCO..Amazon_Credenciales aws 
	WHERE	IdAplicacion				=	@IdAplicacion
	and		aws.Esactivo				=	1
end