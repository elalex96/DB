-- =============================================
-- Author:		DANIEL Cruz
-- Create date: 05-07-17
-- Description:	
-- =============================================
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 12/03/2018
-- Description:	se agrega el retorno del usuario y del proveedor
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_ActualizarAprobacionCNDetalle]
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdAceptacionCartaPCN int,
@IdUsuario int, 
@IdEstatus int,
@Comentario nvarchar(MAX)

 
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		 declare @IdUsuarioCarga int 
		  declare @Idaceptacionservi int 
		 declare @statusnombre nvarchar(MAX)
		 DECLARE @statusNombreEn NVARCHAR(MAX)
    -- Insert statements for procedure here

       UPDATE [dbo].[MM_AceptacionCartaPCN]
		SET [IdEstatus]= @IdEstatus,
		[ComentarioEvaluador] = @Comentario,
		[FechaEvaluacion] =getdate(),
		[IdUsuarioEvaluador] = @IdUsuario
		WHERE [IdAceptacionCartaPCN]=@IdAceptacionCartaPCN


		set @IdUsuarioCarga = (SELECT [CreadoPor] FROM [MM_AceptacionCartaPCN] WHERE [IdAceptacionCartaPCN] =@IdAceptacionCartaPCN)
		set @Idaceptacionservi =(SELECT [IdAceptacionPedido] FROM [MM_AceptacionCartaPCN] WHERE [IdAceptacionCartaPCN] =@IdAceptacionCartaPCN)


		set @statusnombre = (select [TipoValidacion] from [dbo].[S_TipoValidacionDoc] where IdTipoValidacionDoc= @IdEstatus )
		SET @statusNombreEn = (select TipoValidacionEn from [dbo].[S_TipoValidacionDoc] where IdTipoValidacionDoc= @IdEstatus )

		(Select usuario.nombre,@Idaceptacionservi,@statusnombre, Correo, uProv.IdUsuario, uProv.IdProveedor,@statusNombreEn from S_Usuario usuario INNER JOIN dbo.S_UsuarioProveedor uProv ON uProv.IdUsuario = usuario.IdUsuario  where usuario.IdUsuario= @IdUsuarioCarga)
	

		-- En esta seccion se agrega que si la carta de contenido ya contiene un registro este se debe de actualizar el PCN 
		-- esto debido a que la carta de contenido se puede editar y los PCN tanto de adinco como petrovendor no se editaban
		IF(@IdEstatus=2) -- si es aprobado
			BEGIN
				IF EXISTS (SELECT	1
						   FROM dbo.MM_AceptacionCartaPCN pcn
								INNER JOIN dbo.MM_AceptacionFactura af ON af.IdAceptacionPedido=pcn.IdAceptacionPedido
								INNER JOIN dbo.CO_Registro r ON r.IdFactura=af.IdFactura
						   WHERE pcn.IdAceptacionCartaPCN=@IdAceptacionCartaPCN)
					BEGIN
						DECLARE @Registros TABLE(IdRegistro INT)

						INSERT INTO @Registros(IdRegistro)
									SELECT	r.IdRegistro
									FROM	dbo.MM_AceptacionCartaPCN pcn
											INNER JOIN dbo.MM_AceptacionFactura af ON af.IdAceptacionPedido=pcn.IdAceptacionPedido
											INNER JOIN dbo.CO_Registro r ON r.IdFactura=af.IdFactura
									WHERE	pcn.IdAceptacionCartaPCN=@IdAceptacionCartaPCN

						UPDATE	r
						SET r.PCN=apd.PCN
						FROM	dbo.CO_Registro r
								INNER JOIN dbo.MM_AceptacionPedidoDetalle apd ON apd.IdAceptacionPedidoDetalle=r.IdAceptacionPedidoDetalle
								INNER JOIN @Registros filtro ON filtro.IdRegistro=r.IdRegistro
								WHERE  r.PCN<>apd.PCN

						UPDATE	r
						SET r.PCN=SUBSTRING(CAST(apd.PCN AS NVARCHAR(50)),1,5)
						FROM	Adinco.dbo.CO_Registro r
								INNER JOIN dbo.CO_RelacionRegistroAdinco rel ON rel.IdRegistroAdinco=r.IdRegistro
								INNER JOIN @Registros filtro ON filtro.IdRegistro=rel.IdRegistroPetrovendor
								INNER JOIN dbo.CO_Registro rpetro ON rpetro.IdRegistro=rel.IdRegistroPetrovendor
								INNER JOIN dbo.MM_AceptacionPedidoDetalle apd ON apd.IdAceptacionPedidoDetalle=rpetro.IdAceptacionPedidoDetalle
								WHERE  r.PCN<>apd.PCN
					END
			END
 END;


