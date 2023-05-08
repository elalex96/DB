
CREATE PROCEDURE p_AWS_CredencialesIAMByApp
(
	@IdAplicacion int
)
as
BEGIN


EXEC Adinco.dbo.p_AWS_CredencialesIAMByAplication @IdAplicacion = @IdAplicacion -- int

		--SELECT	aws.Id,
		--		aws.AccessKey,
		--		aws.SecretKey,
		--		aws.ServiceUrl,
		--		aws.DefaultBucket
		--FROM	ADINCO..Amazon_Credenciales aws 
		--WHERE	IdAplicacion				=	2
		--and		aws.Esactivo				=	1

end
