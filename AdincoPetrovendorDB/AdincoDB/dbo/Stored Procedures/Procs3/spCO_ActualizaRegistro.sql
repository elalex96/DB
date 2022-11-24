-- =============================================
-- Author:		Miguel Gomez
-- Create date: Diciembre 2014
-- Description:	Inserta un nuevo registro
-- =============================================
CREATE PROCEDURE [dbo].[spCO_ActualizaRegistro] 
	-- Add the parameters for the stored procedure here
@IdRegistro int,
@IdPrograma int ,
@IdFactura int ,
@MontoRegistro decimal(18, 4) ,
@InicioEjecucion date ,
@FinEjecucion date ,
@Comentarios nvarchar(MAX) ,
@MesPresentacion date ,
@IdEstado int ,
@IdUsuarioCreadoPor int ,
@IdUsuarioModPor int ,
@FecMovto datetime ,
@IdInstalacion int 





AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @insertado int
	
	declare @mesge date
	SELECT @mesge = MesGE   from CO_MesGEActualContrato MGE
	JOIN CO_Contrato CON ON CON.IdContrato = MGE.IdContrato     
	JOIN CO_AnioContractual ANC  ON ANC.IdContrato = CON.IdContrato    
	JOIN CO_Presupuesto PRE ON    PRE.IdAnioContractual = ANC.IdAnioContractual 
	JOIN   CO_LineaPresupuestoMes  PRO ON PRO.IdPresupuesto =PRE.IdPresupuesto 
	WHERE PRO.IdLineaPresupuestoMes = @IdPrograma         
	  
    -- Insert statements for procedure here
	--select @IdEstado = idLista from Listas where IdGrupo = 2 and Clave = @IdEstado
UPDATE [dbo].CO_Registro 
   SET [IdPrograma] = @IdPrograma
      ,[IdFactura] =@IdFactura
      ,[MontoRegistro] = @MontoRegistro
      ,[InicioEjecucion] = @InicioEjecucion
      ,[FinEjecucion] = @FinEjecucion
      ,[Comentarios] = @Comentarios
      ,[MesPresentacion] = @mesge
      ,[IdEstado] = @IdEstado
      ,[IdUsuarioCreadoPor] = @IdUsuarioCreadoPor
      ,[IdUsuarioModPor] = @IdUsuarioModPor
      ,[FecMovto] = CURRENT_TIMESTAMP
      ,[IdInstalacion] = @IdInstalacion
 WHERE IdRegistro = @IdRegistro
        
						INSERT INTO [dbo].CO_RegistroLog 
           ([IdRegistro]
		   ,[IdPrograma]
           ,[IdFactura]
           ,[MontoRegistro]
           ,[InicioEjecucion]
           ,[FinEjecucion]
           ,[Comentarios]
           ,[MesPresentacion]
           ,[IdEstado]
           ,[IdUsuarioCreadoPor]
           ,[IdUsuarioModPor]
           ,[FecMovto]
           ,[IdInstalacion])
     VALUES
           (@IdRegistro,
		    @IdPrograma ,
			@IdFactura ,
			@MontoRegistro ,
			@InicioEjecucion ,
			@FinEjecucion ,
			@Comentarios ,
			@mesge ,
			2 ,
			@IdUsuarioCreadoPor ,
			@IdUsuarioModPor ,
			CURRENT_TIMESTAMP  ,
			@IdInstalacion )
			SELECT @IdRegistro AS INSERTADO , concat('El registro se ha actualizado exitosamente con el id ' , @IdRegistro)  as MSG


END

