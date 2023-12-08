`timescale 1ns / 1ps

module tb_apb;

  // Параметры шины APB
  parameter addrWidth = 32;
  parameter dataWidth = 32;
  apb IF(clk,rst);
  // Сигналы шины APB
  logic clk, rst, psel, penable, pwrite, pslverr;
  logic [ addrWidth-1 : 0 ]  PADDR;
  logic [ dataWidth-1 : 0 ] PWDATA;
  logic [ dataWidth/8-1 : 0 ] pstrb;

    apbMaster apbMaster(clk, rst, IF.masterAPB, pprot,
        pselx,
        penable,
        pwrite,
        pstrb
        paddr, 
        pwdata,
        pslverr,
        pready,
        pradata)
          // Модуль тестирования
  initial begin
    // Инициализация сигналов
    pclk = 0;
    presetn = 0;
    psel = 0;
    penable = 0;
    pwrite = 0;
    PADDR = 0;
    PWDATA = 0;
    PSTRB = 0;
    PWDATA_byte_enable = 0;

    // Запуск сигнала тактового сигнала
    forever #5 pclk = ~pclk;

    // Запуск теста
    test();

  end

  // Тестовая процедура
  task test();
    // Сброс
    presetn = 1;
    #10;

    // Транзакция чтения
    psel = 1;
    penable = 1;
    pwrite = 0;
    PADDR = $urandom_range(0, 2**PADDR_WIDTH-1);
    #10;

    // Транзакция записи
    psel = 1;
    penable = 1;
    pwrite = 1;
    PADDR = $urandom_range(0, 2**PADDR_WIDTH-1);
    PWDATA = $urandom_range(0, 2**PDATA_WIDTH-1);
    PSTRB = $urandom_range(0, 2**(PDATA_WIDTH/8)-1);
    #10;

    // Завершение теста
    $stop;
  endtask

endmodule
