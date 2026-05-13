-- =============================================  
-- Author: Daniel AC  
-- Create date: 08-04-2021  
-- Description: Actualizar estatus de aprobación de factura de mercadeo
-- =============================================  
-- Author: Luis David
-- Create date: 19/07/2022
-- Description: Cuando la factura sea de carso se elimnina la transferencia de AX_Pago Issue #1936 (Petrovendor)
-- =============================================  
CREATE  PROCEDURE [dbo].[AD_SP_CambiarEstatusFacturaMercadeo] 
@IdProveedor INT,  
@IdAceptacionPedido INT,
@IdFactura INT,
@IdOperacion INT,
@Comentario NVARCHAR(MAX),
@IdTareaEspecifico INT,
@EsReinicioPorTarea BIT 
AS  
 BEGIN  
  SET NOCOUNT ON  
  DECLARE @ReceptorFactura varchar(300), @IdAsiento varchar(300), @UUIDPrincipal varchar(300);
  DECLARE @IdFacturaAdinco INT 
  DECLARE @FechaModificacion DATETIME  = GETDATE()  
  DECLARE @TotalAprobadores INT 
  DECLARE @AprobadoresEnAprobacion INT
  DECLARE @EstatusAprobacion INT 
  DECLARE @NombreEstatusAprobacion NVARCHAR(MAX) 
  DECLARE @NombreAprobador NVARCHAR(MAX) 
  DECLARE @ExisteTareaId INT
  DECLARE @ComentarioLargo NVARCHAR(MAX) 
  DECLARE @NoSecuenciaTareaId INT
  DECLARE @TipoFlujoAprobacion INT
  CREATE TABLE #APROBADORES(IdTarea INT)  
  
   --BUSCAR SI EXISTE FACTURA RELACIONA EN ADINCO
    SELECT 
	@IdFacturaAdinco = ISNULL(FA.IdFactura,0) 
    FROM MM_AceptacionFactura AS AF  
        JOIN FI_Factura AS F  
            ON F.IdFactura = AF.IdFactura  
        JOIN TA_Operacion AS O  
            ON O.IdDocumento = AF.IdAceptacionFactura          
        JOIN MM_AceptacionPedido AS AP  
            ON AP.IdAceptacionPedido = AF.IdAceptacionPedido  
        JOIN MM_Pedido AS PE  
            ON PE.IdPedido = AP.IdPedido        
		LEFT JOIN Adinco.dbo.FI_Factura  AS FA 
			ON  F.UUID = FA.UUID  COLLATE SQL_Latin1_General_CP1_CI_AS 
    WHERE O.IdTipoOperacion = 10  --> APROBACIÓN DE TIPO FACTURA  	 
          AND PE.IdProveedorCompras = @IdProveedor  
          AND AF.IdAceptacionPedido =@IdAceptacionPedido ---> 441  
    GROUP BY FA.IdFactura

  --SI HAY FACTURA EN ADINCO NO SE PUEDE REINICIAR EL FLUJO DE APROBACIÓN
   IF ISNULL(@IdFacturaAdinco,0)>0
   BEGIN 
		 SELECT 'HAY_FACTURA_EN_ADINCO' AS Response,@IdFacturaAdinco AS FacturaAdincoId  
		RETURN;
   END 

     --OBTENER TOTAL DE APROBADORES ACTIVOS DE LA APROBACIÓN
	 SELECT 
	 @TotalAprobadores=COUNT(1)
	 FROM TA_Tarea
	 WHERE 
	 IdOperacion = @IdOperacion
	 AND Activo=1  

	 --OBTENER NUMERO DE APROBADORES ACTIVOS EN APROBACIÓN
	 SELECT 
	 @AprobadoresEnAprobacion=COUNT(1)
	 FROM TA_Tarea
	 WHERE 
	 IdOperacion = @IdOperacion
	 AND Activo=1  
	 AND IdEstatus=1 ---> EN APROBACIÓN

	 --OBTENER ESTATUS DE LA APROBACIÓN DE FACTURA, ASI COMO EL TIPO DE FLUJO(SERIAL-->1/PARALELO-->2)
	 SELECT @EstatusAprobacion=O.IdEstatusOperacion,
	 @TipoFlujoAprobacion = FT.IdTipoFlujo,
	 @NombreEstatusAprobacion = E.Nombre
	 FROM TA_Operacion O
	 LEFT JOIN TA_Estatus E
		ON O.IdEstatusOperacion= E.IdEstatus
	 LEFT JOIN TA_FlujoTarea FT 
		ON O.IdFlujoTarea = FT.IdFlujoTarea
	 WHERE O.IdOperacion=@IdOperacion
	 
	 ---> SI TODOS LOS APROBADORES ESTAN EN APROBACIÓN Y LA APROBACIÓN GRAL TAMBIEN YA NO REALIZAR CAMBIO
	 IF @TotalAprobadores=@AprobadoresEnAprobacion AND @EstatusAprobacion=1
	 BEGIN
		SELECT 'YA_ESTA_EN_APROBACIÓN' AS Response
		RETURN;
	 END 

	 /*REINICIAR APROBACIÓN DE FACTURA POR  APROBADOR(TAREA) */
	 IF @EsReinicioPorTarea = 1
	 BEGIN 
	       --PARA ESTO TODA LA APROBACIÓN DEBE ESTAR EN ESTATUS RECHAZADO O APROBADO
		    IF @EstatusAprobacion NOT IN  (2,3)
			BEGIN
				SELECT 'NO_RECHAZADO_NI_APROBADO' AS Response, 'LA APROBACIÓN TIENE QUE ESTAR COMO RECHAZADA O APROBADA PARA CONTINUAR'
				RETURN;
			END 

			--OBTENER DETALLE DE LA TAREA DEL APROBADOR
			SELECT 
			@ExisteTareaId =T.IdTarea,
			@NombreAprobador= U.Nombre,
			@NoSecuenciaTareaId= T.NoSecuencia
			FROM TA_Tarea T
			JOIN S_Usuario U
			ON T.IdAprobador=U.IdUsuario
			WHERE T.IdTarea=@IdTareaEspecifico
			AND T.Activo=1 --> LA TAREA DEBE ESTAR ACTIVA 
			AND T.IdOperacion=@IdOperacion

			IF ISNULL(@ExisteTareaId,0) = 0
			BEGIN 
				SELECT 'APROBADOR_NO_ENCONTRADO' AS Response, 'EL APROBADOR NO EXISTE EN LA APROBACIÓN, VALIDAR O RECARGAR LA LISTA DE APROBADORES'
				RETURN;
			END 

			SET @ComentarioLargo = CONCAT('Se reinicio la tarea de aprobación del usuario: ',
											ISNULL(@NombreAprobador,'x'),' por lo tanto',
											' la aprobación de factura, paso del Estatus: ',isnull(@NombreEstatusAprobacion,'x'),' al estatus En Aprobación. Comentario:',@Comentario)

			-- AGREGAR AL HISTORIAL DEL REINICIO DE APROBACIÓN DEL APROBADOR ASI COMO DEL FLUJO DE APROBACIÓN DE LA FACTURA
			INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)  
			SELECT    
			@ComentarioLargo,  
			@IdOperacion,  
			@FechaModificacion,  
			6--> TAREA REINICIADA DE  SELECT * FROM dbo.TA_EstadoFlujoTarea WHERE Idestado=6 
			   
		    /*ACTUALIZAR LAS APROBACION DE UN APROBADOR ESPECIFICO*/
			UPDATE dbo.TA_Tarea
			SET 
			IdEstatus = 1,---> EN APROBACIÓN
			Comentario='',
			FechaCambioEstatus=NULL
			WHERE IdOperacion = @IdOperacion
			AND Activo=1  
			AND IdTarea = @IdTareaEspecifico

			IF ISNULL(@TipoFlujoAprobacion,0)=1 -->SOLO APLICA SI EL FLUJO ES SERIAL
			BEGIN 
				/*SI EL FLUJO ES SERIAL SE TIENE QUE REINICIAR LOS APROBADORES DE SECUENCIA MAYOR AL APROBADOR ACTUAL*/
				  INSERT INTO #APROBADORES (IdTarea) 
				  SELECT IdTarea
				  FROM TA_Tarea 
				  WHERE IdOperacion= @IdOperacion 
				  AND Activo=1  
				  AND NoSecuencia>@NoSecuenciaTareaId

				    UPDATE T
					SET 
					IdEstatus = 1,---> EN APROBACIÓN
					Comentario='',
					FechaCambioEstatus=NULL
					FROM TA_Tarea T
					JOIN #APROBADORES A
					ON T.IdTarea=A.IdTarea
					WHERE T.IdOperacion = @IdOperacion
					AND T.Activo=1  

					-- AGREGAR AL HISTORIAL LOS APROBADORES QUE SE LES REINICIO SU APROBACIÓN
					INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)  
					SELECT    
					CONCAT('Se reinicio la tarea de aprobación al usuario ',
							ISNULL(UE.Nombre,' usuario no identificado '),
							', debido a que se reinicio la tarea de aprobación al usuario: ',
							ISNULL(@NombreAprobador,'x'),
							' y el tipo de flujo de la aprobación es de tipo Serial'),  
					@IdOperacion,  
					@FechaModificacion,  
					6--> TAREA REINICIADA DE  SELECT * FROM dbo.TA_EstadoFlujoTarea WHERE Idestado=6  
					FROM dbo.TA_Tarea  T  
					JOIN #APROBADORES A
					ON T.IdTarea=A.IdTarea
					LEFT JOIN S_Usuario UE
					ON T.IdAprobador=UE.IdUsuario
					WHERE T.IdOperacion = @IdOperacion
					AND T.Activo=1	

			END 

			/*SI EL ESTATUS ES RECHAZADO PASAR TODOS LOS ESTATUS DEL ESTADO Cancelado por Rechazo Al estatus en Aprobación* SEA SERIAL O PARALELO*/
			UPDATE T
			SET 
			IdEstatus = 1,---> EN APROBACIÓN
			Comentario='',
			FechaCambioEstatus=NULL
			FROM TA_Tarea T		
			WHERE T.IdOperacion = @IdOperacion
			AND T.Activo=1 
			AND (T.IdEstatus=4 OR T.IdEstatus=3)--> (4)Cancelado por Rechazo O (3)Rechazada


	 END 
	 ELSE 	 
	 BEGIN 
		 /*REINICIO DE TODA LA APROBACIÓN Y DE TODOS LOS APROBADORES*/
		 -- AGREGAR AL HISTORIAL DEL REINICIO DE APROBACIÓN 
		  INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)  
		  SELECT    
		  CONCAT('Se reinicio flujo de aprobación de factura, del estatus ',isnull(@NombreEstatusAprobacion,'x'),' al estatus En Aprobación. Comentario:',@Comentario),  
		  @IdOperacion,  
		  @FechaModificacion,  
		  6--> TAREA REINICIADA DE  SELECT * FROM dbo.TA_EstadoFlujoTarea WHERE Idestado=8  
 
		/*ACTUALIZAR LAS APROBACIONES DE TODOS LOS APROBADORES ACTIVOS DE LA APROBACIÓN DE FACTURA*/
		UPDATE dbo.TA_Tarea
		SET 
		IdEstatus = 1,---> EN APROBACIÓN
		Comentario='',
		FechaCambioEstatus=NULL
		WHERE IdOperacion = @IdOperacion
		AND Activo=1  
	END 

	/*CAMBIOS GENERALES DE REINICIO DE FLUJO DE APROBACIÓN DE FACTURA*/
	BEGIN 
	   --->ACTUALIZAR ESTATUS DE LA FACTURA 
		 UPDATE dbo.MM_AceptacionFactura
		 SET 
			  IdEstatusXML = 1, --> EN APROBACIÓN
			  IdEstatusPDF = 1  --> EN APROBACIÓN
		 WHERE IdAceptacionPedido = @IdAceptacionPedido;       

		--->ACTUALIZAR ESTATUS DE APROBACIÓN
		 UPDATE dbo.TA_Operacion
		  SET 
			  IdEstatusOperacion = 1, --> EN APROBACIÓN
			  IdEstadoFlujo = 2  --> 
		 WHERE IdOperacion = @IdOperacion;
		
		--> DESACTIVAR LA RELACION DE FACTURA DE LA FACTURA SI ESQUE YA SE HABIA ENVIADO A ADINCO
		UPDATE Adinco.dbo.FI_FacturaAdincoPetrovendor
		SET 
		Activo = 0
		WHERE IdFacturaPetrovendor = @IdFactura;
		--> Si la factura es de Carso se elimina la transferencia de Ax_Pago para poder hacer el envio correcto por el ws

		SELECT top 1
			@ReceptorFactura = f.Receptor,
			@IdAsiento = pl.RECID,
			@UUIDPrincipal = pl.UUIDFacturaPagada
		FROM Petrovendor..AX_Pagos pl
		join FI_Factura as f on pl.UUIDFacturaPagada = f.UUID
		join S_Proveedor as p on f.Receptor = p.RFC
		left join adinco..FI_Factura as fa on f.UUID collate SQL_Latin1_General_CP1_CI_AS = fa.UUID collate SQL_Latin1_General_CP1_CI_AS
		where f.IdFactura = @IdFactura
		IF	@ReceptorFactura = 'OBD1708213QA' OR @ReceptorFactura = 'OBT1708213V6'
		BEGIN
			UPDATE AX_Pagos
			SET IdTransferencia = NULL
			WHERE recid = @IdAsiento
			
			insert into Ax_BitacoraCarso (
			ErrorMotivo,
			Lugar,
			RecId, 
			Accion,
			FechaRegistro,
			UUID_Principal,
			IdAsientoPago) values (
			concat('Se elimina la transferencia por Reversa de Factura, Comentario: ',@Comentario,' Aceptación: ',@IdAceptacionPedido),
			'AD_SP_CambiarEstatusFacturaMercadeo',
			@IdAsiento,
			'Reversa Factura',
			GETDATE(),
			@UUIDPrincipal,
			@IdAsiento)

		END
	END 
	SELECT 'SUCCESS'
	 
  
 END