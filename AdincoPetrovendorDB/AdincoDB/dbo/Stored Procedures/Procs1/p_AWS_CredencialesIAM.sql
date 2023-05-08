--================================
--== CREADO POR: LUIS DAVID
--== DESCRIPCION: CONSULTA LAS CREDENCIALES DE LA APLICACION AMAZON S3
--== CREADO EL: 25 JULIO 2019
CREATE PROCEDURE [dbo].[p_AWS_CredencialesIAM]
@Id int
as
begin
	SELECT 
	aws.Id
	,aws.AccessKey
	,aws.SecretKey
	,aws.ServiceUrl
	,aws.DefaultBucket
	FROM ADINCO..Amazon_Credenciales aws 
		WHERE IdAplicacion = @Id
		and aws.Esactivo =1
end